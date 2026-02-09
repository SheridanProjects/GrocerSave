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

// --- DATABASE INITIALIZATION ---
const initDb = async () => {
  try {
    // You mentioned you already added products, so this table likely exists.
    // We'll create it just in case for fresh environments.
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT
      );
    `);
    console.log("Database 'products' table checked/created successfully.");
  } catch (err) {
    console.error("Error initializing database:", err);
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
app.listen(port, () => {
  console.log(`Catalog Service listening on port ${port}`);
  initDb();
});