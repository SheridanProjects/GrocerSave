const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 8181;

app.use(cors());
app.use(express.json());

// --- DATABASE CONNECTION ---
// It assumes the table has been created manually.
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'grocer_admin',
  host: process.env.DB_HOST || 'postgres',
  database: process.env.POSTGRES_DB || 'grocersave_db',
  password: process.env.POSTGRES_PASSWORD || 'dev_secret_123',
  port: 5432,
});

// --- API ENDPOINTS ---
app.get('/health', (req, res) => {
  pool.query('SELECT NOW()', (err, result) => {
    if (err) {
      res.status(500).json({ status: 'DOWN', error: 'Postgres connection failed' });
    } else {
      res.json({ status: 'UP', service: 'catalog-service' });
    }
  });
});

// GET /products - Fetches all products from the database
app.get('/products', async (req, res) => {
  try {
    // The query now assumes the 'id' column is of type UUID
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
});
