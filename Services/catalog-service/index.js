const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 8181;

app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: process.env.POSTGRES_USER || 'grocer_admin',
  host: process.env.DB_HOST || 'postgres',
  database: process.env.POSTGRES_DB || 'grocersave_db',
  password: process.env.POSTGRES_PASSWORD || 'dev_secret_123',
  port: 5432,
});

app.get('/health', (req, res) => {
  res.json({ status: 'UP', service: 'catalog-service' });
});

app.listen(port, () => {
  console.log(`Catalog Service listening on port ${port}`);
});