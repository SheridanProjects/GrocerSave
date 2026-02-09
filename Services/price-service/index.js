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
});

// --- DATABASE INITIALIZATION with RETRY LOGIC ---
const initDb = async () => {
  let retries = 5;
  while (retries) {
    try {
      await client.connect();
      console.log("Successfully connected to Cassandra.");

      await client.execute(`
        CREATE KEYSPACE IF NOT EXISTS price_service
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};
      `);
      console.log("Keyspace 'price_service' checked/created successfully.");

      client.keyspace = 'price_service';

      await client.execute(`
        CREATE TABLE IF NOT EXISTS price_history (
          product_id uuid,
          store_id uuid,
          price decimal,
          is_on_sale boolean,
          recorded_at timestamp,
          PRIMARY KEY (product_id, recorded_at)
        ) WITH CLUSTERING ORDER BY (recorded_at DESC);
      `);
      console.log("Cassandra 'price_history' table checked/created successfully.");

      return;

    } catch (err) {
      console.error("Error initializing Cassandra, retrying...", err.message);
      retries -= 1;
      if (retries === 0) {
        console.error("Could not initialize Cassandra after multiple retries. Exiting.");
        throw err;
      }
      await new Promise(res => setTimeout(res, 5000));
    }
  }
};

// --- HELPER FUNCTION ---
const parseRowPrices = (rows) => {
  if (!rows) return [];
  return rows.map(row => {
    // Correctly map the columns from the database to the expected JSON output
    return {
      product_id: row.product_id,
      // The BFF expects store_name, but the DB has store_id. We will send the ID
      // and eventually, the BFF would look up the name from a (future) store service.
      // For now, we will alias it to make the data flow work.
      store_name: row.store_id.toString(), // Sending UUID as a string
      price: parseFloat(row.price.toString()),
      timestamp: row.recorded_at
    };
  });
};

// --- API ENDPOINTS ---
app.get('/health', (req, res) => {
  client.execute('SELECT now() FROM system.local', (err, result) => {
    if (err) {
      res.status(500).json({ status: 'DOWN', error: 'Cassandra connection failed' });
    } else {
      res.json({ status: 'UP', service: 'price-service' });
    }
  });
});

app.get('/prices/:productId', async (req, res) => {
  const { productId } = req.params;
  try {
    const query = 'SELECT * FROM price_history WHERE product_id = ?';
    const result = await client.execute(query, [productId], { prepare: true });
    res.json(parseRowPrices(result.rows));
  } catch (err) {
    console.error(`Error fetching prices for product ${productId}:`, err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.get('/prices/latest', async (req, res) => {
  try {
    const query = 'SELECT * FROM price_history';
    const allPrices = await client.execute(query);

    const latestPrices = {};
    allPrices.rows.forEach(row => {
      if (!latestPrices[row.product_id] || row.recorded_at > latestPrices[row.product_id].recorded_at) {
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
    console.error("Failed to start Price Service due to DB initialization failure.");
    process.exit(1);
});