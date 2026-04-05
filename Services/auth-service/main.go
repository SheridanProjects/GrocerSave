package main

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"
	_ "github.com/lib/pq"
)

var (
	rdb *redis.Client
	db  *sql.DB
	ctx = context.Background()
)

type UserCredentials struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Email    string `json:"email"`
}

// --- JSON Error Helper ---
func respondWithError(w http.ResponseWriter, message string, code int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(map[string]string{"error": message})
}

func main() {
	// --- CONFIG ---
	dbHost := os.Getenv("DB_HOST")
	redisHost := os.Getenv("REDIS_HOST")

	if redisHost == "" { redisHost = "localhost:6379" }
	if !strings.Contains(redisHost, ":") { redisHost += ":6379" }

	rdb = redis.NewClient(&redis.Options{ Addr: redisHost })

	dbUser := os.Getenv("POSTGRES_USER")
	dbPass := os.Getenv("POSTGRES_PASSWORD")
	dbName := os.Getenv("POSTGRES_DB")

	if dbUser == "" { dbUser = "grocer_admin" }
	if dbPass == "" { dbPass = "dev_secret_123" }
	if dbName == "" { dbName = "grocersave_db" }
	if dbHost == "" { dbHost = "postgres" }

	connStr := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable", dbHost, dbUser, dbPass, dbName)

	var err error
	for i := 0; i < 5; i++ {
		db, err = sql.Open("postgres", connStr)
		if err == nil {
			err = db.Ping()
		}
		if err == nil {
			break
		}
		log.Printf("Waiting for DB... (%d/5)", i+1)
		time.Sleep(2 * time.Second)
	}
	if err != nil { log.Fatal("Could not connect to DB:", err) }

	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS users (
		username TEXT PRIMARY KEY,
		password_hash TEXT NOT NULL,
		email TEXT UNIQUE NOT NULL
	)`)
	if err != nil { log.Printf("DB Warning: %v", err) }

	http.HandleFunc("/signup", handleSignup)
	http.HandleFunc("/login", handleLogin)
	http.HandleFunc("/validate", handleValidate)
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		w.Write([]byte("OK"))
	})

	port := os.Getenv("PORT")
	if port == "" { port = "8180" }

	log.Printf("🔐 Auth Service Securely Ready on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

// --- SECURITY HELPERS ---
func generateRandomToken() string {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return fmt.Sprintf("fallback_%d", time.Now().UnixNano())
	}
	return hex.EncodeToString(b)
}

func hashPassword(password string) string {
	salt := "GrocerSave_Salt_v1_"
	h := sha256.New()
	h.Write([]byte(salt + password))
	return hex.EncodeToString(h.Sum(nil))
}

// --- HANDLERS ---
func handleValidate(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		respondWithError(w, "Missing token", http.StatusBadRequest)
		return
	}

	username, err := rdb.Get(ctx, token).Result()
	if err == redis.Nil {
		respondWithError(w, "Invalid Token", http.StatusUnauthorized)
		return
	} else if err != nil {
		respondWithError(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"uid": username, "valid": "true"})
}

func handleSignup(w http.ResponseWriter, r *http.Request) {
	enableCors(w)
	if r.Method == "OPTIONS" { w.WriteHeader(http.StatusOK); return }
	if r.Method != "POST" {
		respondWithError(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds UserCredentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		respondWithError(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	username := strings.ToLower(strings.TrimSpace(creds.Username))
	password := strings.TrimSpace(creds.Password)
	email := strings.ToLower(strings.TrimSpace(creds.Email))

	if username == "" || password == "" || email == "" {
		respondWithError(w, "All fields are required", http.StatusBadRequest)
		return
	}

	hash := hashPassword(password)

	_, err := db.Exec("INSERT INTO users (username, password_hash, email) VALUES ($1, $2, $3)", username, hash, email)
	if err != nil {
		respondWithError(w, "User with that username or email already exists", http.StatusConflict)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"message": "User created successfully"})
}

func handleLogin(w http.ResponseWriter, r *http.Request) {
	enableCors(w)
	if r.Method == "OPTIONS" { w.WriteHeader(http.StatusOK); return }
	if r.Method != "POST" {
		respondWithError(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds UserCredentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		respondWithError(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	username := strings.ToLower(strings.TrimSpace(creds.Username))
	password := strings.TrimSpace(creds.Password)

	var storedHash string
	err := db.QueryRow("SELECT password_hash FROM users WHERE username=$1", username).Scan(&storedHash)
	if err != nil {
		respondWithError(w, "Invalid username or password", http.StatusUnauthorized)
		return
	}

	if hashPassword(password) != storedHash {
		respondWithError(w, "Invalid username or password", http.StatusUnauthorized)
		return
	}

	sessionToken := generateRandomToken()
	err = rdb.Set(ctx, sessionToken, username, 24*time.Hour).Err()
	if err != nil {
		log.Printf("Redis Error: %v", err)
		respondWithError(w, "Could not create session", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"token": sessionToken,
		"uid":   username,
	})
}

func enableCors(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
}
