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

// --- HELPER FUNCTION ---
const parseRowPrices = (rows) => {
  if (!rows) return [];
  return rows.map(row => {
    return {
      product_id: row.product_id,
      store_name: row.store_id.toString(),
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

// CORRECTED ROUTE ORDER
// The more specific route '/latest' must be defined BEFORE the dynamic route '/:productId'.
app.get('/prices/latest', async (req, res) => {
  try {
    const query = 'SELECT * FROM price_history';
    const allPrices = await client.execute(query);

    const latestPrices = {};
    allPrices.rows.forEach(row => {
      const productIdStr = row.product_id.toString();
      if (!latestPrices[productIdStr] || row.recorded_at > latestPrices[productIdStr].recorded_at) {
        latestPrices[productIdStr] = row;
      }
    });

    res.json(parseRowPrices(Object.values(latestPrices)));
  } catch (err) {
    console.error("Error fetching latest prices:", err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
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


// --- SERVER START ---
// The application no longer handles schema creation.
app.listen(port, () => {
  console.log(`Price Service listening on port ${port}`);
});
