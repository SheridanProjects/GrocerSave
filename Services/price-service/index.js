const express = require('express');
const cors = require('cors');
const cassandra = require('cassandra-driver');

const app = express();
const port = process.env.PORT || 8182;

app.use(cors());
app.use(express.json());

// --- DATABASE CONNECTION ---
const client = new cassandra.Client({
  contactPoints: [(process.env.CASSANDRA_HOST || 'cassandra')],
  localDataCenter: 'datacenter1',
  keyspace: 'price_service'
});

// --- DATABASE INITIALIZATION ---
const initDb = async () => {
  try {
    await client.connect();
    console.log('Connected to Cassandra.');
    await client.execute(`
      CREATE KEYSPACE IF NOT EXISTS price_service
      WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};
    `);
    await client.execute(`
      CREATE TABLE IF NOT EXISTS price_service.price_history (
        product_id INT,
        store_name TEXT,
        price DECIMAL,
        timestamp TIMESTAMP,
        PRIMARY KEY (product_id, timestamp)
      ) WITH CLUSTERING ORDER BY (timestamp DESC);
    `);
    console.log("Cassandra 'price_history' table checked/created successfully.");
  } catch (err) {
    console.error("Error initializing Cassandra:", err);
  }
};

// --- HELPER FUNCTION ---
// Converts the Cassandra Decimal type to a standard JavaScript number
const parseRowPrices = (rows) => {
  return rows.map(row => ({
    ...row,
    price: parseFloat(row.price.toString())
  }));
};

// --- API ENDPOINTS ---
app.get('/health', (req, res) => {
  res.json({ status: 'UP', service: 'price-service' });
});

app.get('/prices/:productId', async (req, res) => {
  const { productId } = req.params;
  try {
    const query = 'SELECT store_name, price, timestamp FROM price_service.price_history WHERE product_id = ?';
    const result = await client.execute(query, [productId], { prepare: true });
    res.json(parseRowPrices(result.rows));
  } catch (err) {
    console.error(`Error fetching prices for product ${productId}:`, err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.get('/prices/latest', async (req, res) => {
  try {
    const query = 'SELECT product_id, store_name, price, timestamp FROM price_service.price_history';
    const allPrices = await client.execute(query);

    const latestPrices = {};
    allPrices.rows.forEach(row => {
      if (!latestPrices[row.product_id] || row.timestamp > latestPrices[row.product_id].timestamp) {
        latestPrices[row.product_id] = row;
      }
    });

    res.json(parseRowPrices(Object.values(latestPrices)));
  } catch (err) {
    console.error("Error fetching latest prices:", err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// --- SERVER START ---
initDb().then(() => {
  app.listen(port, () => {
    console.log(`Price Service listening on port ${port}`);
  });
}).catch(err => {
    console.error("Failed to start Price Service:", err);
    process.exit(1);
});