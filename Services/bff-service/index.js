const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const port = process.env.PORT || 3100;

app.use(cors());
app.use(express.json());

// Service URLs using the full Kubernetes DNS names for robustness
const AUTH_URL = process.env.AUTH_URL || 'http://auth-service.grocersave-dev.svc.cluster.local:8180';
const CATALOG_URL = process.env.CATALOG_URL || 'http://catalog-service.grocersave-dev.svc.cluster.local:8181';
const PRICE_URL = process.env.PRICE_URL || 'http://price-service.grocersave-dev.svc.cluster.local:8182';

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
    console.error("[BFF] Signup Error:", error.message);
    res.status(error.response?.status || 500).json(error.response?.data || { error: 'Auth Service is unavailable' });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const response = await axios.post(`${AUTH_URL}/login`, req.body);
    res.status(response.status).json(response.data);
  } catch (error) {
    console.error("[BFF] Login Error:", error.message);
    res.status(error.response?.status || 500).json(error.response?.data || { error: 'Auth Service is unavailable' });
  }
});

// --- DEALS AGGREGATION ---
app.get('/deals', async (req, res) => {
  console.log("[BFF] Received request for /deals");
  try {
    // 1. Fetch all products from Catalog Service
    console.log(`[BFF] Calling Catalog Service at ${CATALOG_URL}/products`);
    const productsResponse = await axios.get(`${CATALOG_URL}/products`);
    const products = productsResponse.data;
    console.log(`[BFF] Got ${products.length} products from Catalog Service.`);

    // 2. Fetch the latest price for all products from Price Service
    console.log(`[BFF] Calling Price Service at ${PRICE_URL}/prices/latest`);
    const pricesResponse = await axios.get(`${PRICE_URL}/prices/latest`);
    const latestPrices = pricesResponse.data;
    console.log(`[BFF] Got ${latestPrices.length} prices from Price Service.`);

    // 3. Create a map of prices for easy lookup
    const priceMap = latestPrices.reduce((map, price) => {
      map[price.product_id] = price;
      return map;
    }, {});

    // 4. Combine product info with its latest price
    const deals = products.map(product => {
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

    console.log(`[BFF] Aggregated ${deals.length} deals. Sending to client.`);
    res.json(deals);

  } catch (error) {
    console.error("[BFF] Error aggregating deals:", error.message);
    if (error.response) {
      console.error("[BFF] Downstream service error:", error.response.status, error.response.data);
    }
    res.status(500).json({ error: 'Failed to aggregate deals from backend services' });
  }
});

app.listen(port, () => {
  console.log(`BFF Service listening on port ${port}`);
});