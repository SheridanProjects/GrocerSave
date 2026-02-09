const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const port = process.env.PORT || 3100;

app.use(cors());
app.use(express.json());

const AUTH_URL = process.env.AUTH_URL || 'http://auth-service:8180';
const CATALOG_URL = process.env.CATALOG_URL || 'http://catalog-service:8181';
const PRICE_URL = process.env.PRICE_URL || 'http://price-service:8182';

// --- HEALTH CHECK ---
app.get('/health', (req, res) => {
  res.json({ status: 'UP', service: 'bff-service' });
});

// --- AUTH PROXY ---
app.post('/auth/signup', async (req, res) => {
  try {
    const response = await axios.post(`${AUTH_URL}/signup`, req.body);
    res.status(response.status).json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json(error.response?.data || { error: 'Auth Service is unavailable' });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const response = await axios.post(`${AUTH_URL}/login`, req.body);
    res.status(response.status).json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json(error.response?.data || { error: 'Auth Service is unavailable' });
  }
});

// --- DEALS AGGREGATION ---
app.get('/deals', async (req, res) => {
  try {
    // 1. Fetch all products from Catalog Service
    const productsResponse = await axios.get(`${CATALOG_URL}/products`);
    const products = productsResponse.data;

    // 2. Fetch the latest price for all products from Price Service
    const pricesResponse = await axios.get(`${PRICE_URL}/prices/latest`);
    const latestPrices = pricesResponse.data;

    // 3. Create a map of prices for easy lookup (using string representation of UUID)
    const priceMap = latestPrices.reduce((map, price) => {
      map[price.product_id] = price;
      return map;
    }, {});

    // 4. Combine product info with its latest price
    const deals = products.map(product => {
      // The 'id' from postgres (which is a UUID) is used as the key
      const priceInfo = priceMap[product.id];

      const oldPrice = priceInfo ? (parseFloat(priceInfo.price) * 1.3).toFixed(2) : 'N/A';
      const drop = priceInfo ? '23%' : 'N/A';

      return {
        id: product.id,
        item: product.name,
        store: priceInfo ? priceInfo.store_name : 'Unknown',
        price: priceInfo ? parseFloat(priceInfo.price) : 'N/A',
        oldPrice: oldPrice,
        drop: drop,
        imageUrl: product.image_url
      };
    }).filter(deal => deal.price !== 'N/A');

    res.json(deals);

  } catch (error) {
    console.error("Error aggregating deals:", error.message);
    res.status(500).json({ error: 'Failed to aggregate deals' });
  }
});

app.listen(port, () => {
  console.log(`BFF Service listening on port ${port}`);
});
