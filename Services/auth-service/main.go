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

func main() {
	// --- CONFIG ---
	dbHost := os.Getenv("DB_HOST")
	redisHost := os.Getenv("REDIS_HOST")

	// Default to localhost if not set (for local testing outside k8s)
	if redisHost == "" { redisHost = "localhost:6379" }

	// In K8s, redisHost might be just "redis", so we append port if missing
	if !strings.Contains(redisHost, ":") {
		redisHost = redisHost + ":6379"
	}

	rdb = redis.NewClient(&redis.Options{ Addr: redisHost })

	dbUser := os.Getenv("POSTGRES_USER")
	dbPass := os.Getenv("POSTGRES_PASSWORD")
	dbName := os.Getenv("POSTGRES_DB")

	// Fallback defaults matching k8s-auth.yaml
	if dbUser == "" { dbUser = "grocer_admin" }
	if dbPass == "" { dbPass = "dev_secret_123" }
	if dbName == "" { dbName = "grocersave_db" }
	if dbHost == "" { dbHost = "postgres" }

	connStr := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable", dbHost, dbUser, dbPass, dbName)

	var err error
	// Retry logic for DB connection
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

	// Init Table
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS users (
		username TEXT PRIMARY KEY,
		password_hash TEXT NOT NULL,
		email TEXT UNIQUE NOT NULL
	)`)
	if err != nil { log.Printf("DB Warning: %v", err) }

	http.HandleFunc("/signup", handleSignup)
	http.HandleFunc("/login", handleLogin)
	http.HandleFunc("/validate", handleValidate) // New Endpoint for Microservices

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		w.Write([]byte("OK"))
	})

	port := os.Getenv("PORT")
	if port == "" { port = "8080" } // Default to 8080 if not set, but k8s sets 8180

	log.Printf("🔐 Auth Service Securely Ready on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

// --- SECURITY HELPERS ---

// generateRandomToken creates a 64-char cryptographically secure hex string
func generateRandomToken() string {
	b := make([]byte, 32)
	_, err := rand.Read(b)
	if err != nil { return fmt.Sprintf("fallback_%d", time.Now().UnixNano()) }
	return hex.EncodeToString(b)
}

// hashPassword adds a static salt (better than nothing) and hashes
// In production, use bcrypt and per-user salts.
func hashPassword(password string) string {
	salt := "GrocerSave_Salt_v1_" // Static salt to prevent rainbow table attacks
	h := sha256.New()
	h.Write([]byte(salt + password))
	return hex.EncodeToString(h.Sum(nil))
}

// --- HANDLERS ---

func handleValidate(w http.ResponseWriter, r *http.Request) {
	// Internal endpoint for other services to check tokens
	token := r.URL.Query().Get("token")
	if token == "" {
		http.Error(w, "Missing token", 400)
		return
	}

	// Check Redis
	username, err := rdb.Get(ctx, token).Result()
	if err == redis.Nil {
		http.Error(w, "Invalid Token", 401)
		return
	} else if err != nil {
		http.Error(w, "Internal Error", 500)
		return
	}

	// Return the user associated with the token
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"uid": username, "valid": "true"})
}

func handleSignup(w http.ResponseWriter, r *http.Request) {
	enableCors(w)
	if r.Method == "OPTIONS" { w.WriteHeader(200); return }
	if r.Method != "POST" { http.Error(w, "Method not allowed", 405); return }

	var creds UserCredentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		http.Error(w, "Invalid JSON", 400); return
	}

	username := strings.ToLower(strings.TrimSpace(creds.Username))
	password := strings.TrimSpace(creds.Password)
	email := strings.ToLower(strings.TrimSpace(creds.Email))

	if username == "" || password == "" || email == "" {
		http.Error(w, "All fields required", 400); return
	}

	hash := hashPassword(password)

	_, err := db.Exec("INSERT INTO users (username, password_hash, email) VALUES ($1, $2, $3)", username, hash, email)
	if err != nil {
		http.Error(w, "User exists", 409); return
	}

	w.Header().Set("Content-Type", "application/json") // FIX: Set Content-Type
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte(`{"message": "User created"}`))
}

func handleLogin(w http.ResponseWriter, r *http.Request) {
	enableCors(w)
	if r.Method == "OPTIONS" { w.WriteHeader(200); return }
	if r.Method != "POST" { http.Error(w, "Method not allowed", 405); return }

	var creds UserCredentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		http.Error(w, "Invalid JSON", 400); return
	}

	username := strings.ToLower(strings.TrimSpace(creds.Username))
	password := strings.TrimSpace(creds.Password)

	var storedHash string
	err := db.QueryRow("SELECT password_hash FROM users WHERE username=$1", username).Scan(&storedHash)
	if err != nil {
		http.Error(w, "Invalid credentials", 401); return
	}

	if hashPassword(password) != storedHash {
		http.Error(w, "Invalid credentials", 401); return
	}

	// Generate Secure Token
	sessionToken := generateRandomToken()

	// Store in Redis (24h)
	err = rdb.Set(ctx, sessionToken, username, 24*time.Hour).Err()
	if err != nil { log.Printf("Redis Error: %v", err) }

	w.Header().Set("Content-Type", "application/json") // FIX: Set Content-Type
	json.NewEncoder(w).Encode(map[string]string{
		"token": sessionToken,
		"uid": username,
	})
}

func enableCors(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
}