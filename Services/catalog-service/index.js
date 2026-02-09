const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 8181;

app.use(cors());
app.use(express.json());

// --- DATABASE CONNECTION ---
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'grocer_admin',
  host: process.env.DB_HOST || 'postgres',
  database: process.env.POSTGRES_DB || 'grocersave_db',
  password: process.env.POSTGRES_PASSWORD || 'dev_secret_123',
  port: 5432,
});

// --- DATABASE INITIALIZATION with RETRY LOGIC ---
const initDb = async () => {
  let retries = 5;
  while (retries) {
    try {
      await pool.connect();
      console.log("Successfully connected to PostgreSQL.");

      await pool.query(`
        CREATE TABLE IF NOT EXISTS products (
          id SERIAL PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          image_url TEXT
        );
      `);
      console.log("Database 'products' table checked/created successfully.");
      break; // Exit loop if successful
    } catch (err) {
      console.error("Error initializing database, retrying...", err.message);
      retries -= 1;
      if (retries === 0) {
        console.error("Could not connect to database after multiple retries. Exiting.");
        process.exit(1); // Exit if we can't connect
      }
      // Wait 5 seconds before retrying
      await new Promise(res => setTimeout(res, 5000));
    }
  }
};

// --- API ENDPOINTS ---
app.get('/health', (req, res) => {
  res.json({ status: 'UP', service: 'catalog-service' });
});

// GET /products - Fetches all products from the database
app.get('/products', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT id, name, description, image_url FROM products');
    res.json(rows);
  } catch (err) {
    console.error("Error fetching products:", err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// --- SERVER START ---
initDb().then(() => {
  app.listen(port, () => {
    console.log(`Catalog Service listening on port ${port}`);
  });
}).catch(err => {
    console.error("Failed to start Catalog Service:", err);
});