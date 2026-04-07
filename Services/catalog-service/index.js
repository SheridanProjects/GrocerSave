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

// --- API ENDPOINTS ---
app.get('/health', (req, res) => {
  console.log('Catalog service health check called');
  pool.query('SELECT NOW()', (err, result) => {
    if (err) {
      console.error('Health check failed:', err);
      res.status(500).json({ status: 'DOWN', error: 'Postgres connection failed' });
    } else {
      res.json({ status: 'UP', service: 'catalog-service' });
    }
  });
});

// GET /products - Now supports filtering by search term and category
app.get('/products', async (req, res) => {
  const { search, category } = req.query;

  let query = 'SELECT id, name, description, image_url, category FROM products';
  const params = [];
  const whereClauses = [];

  if (search) {
    params.push(`%${search}%`);
    whereClauses.push(`name ILIKE $${params.length}`);
  }

  if (category) {
    params.push(category);
    whereClauses.push(`category = $${params.length}`);
  }

  if (whereClauses.length > 0) {
    query += ' WHERE ' + whereClauses.join(' AND ');
  }

  try {
    const { rows } = await pool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching products:", err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// GET /categories - A new endpoint to fetch all unique product categories
app.get('/categories', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT DISTINCT category FROM products ORDER BY category');
    res.json(rows.map(row => row.category));
  } catch (err) {
    console.error("Error fetching categories:", err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// --- SERVER START ---
app.listen(port, () => {
  console.log(`Catalog Service listening on port ${port}`);
});
