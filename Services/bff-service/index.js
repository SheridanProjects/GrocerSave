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
  console.log('BFF service health check called');
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
  const { search, category, limit } = req.query;

  try {
    // 1. Fetch products from Catalog Service
    const productsResponse = await axios.get(`${CATALOG_URL}/products`, {
      params: { search, category }
    });
    const products = productsResponse.data;

    // 2. Fetch all prices from Price Service
    let allPrices;
    try {
      const allPricesResponse = await axios.get(`${PRICE_URL}/prices/all`);
      allPrices = allPricesResponse.data;
    } catch (priceError) {
      console.error("Error fetching from price-service:", priceError.response ? priceError.response.data : priceError.message);
      throw new Error('Price service is unavailable or returned an error.');
    }

    // 3. Group prices by product and find the latest and previous prices
    const pricesByProduct = allPrices.reduce((acc, price) => {
      if (!acc[price.product_id]) {
        acc[price.product_id] = [];
      }
      acc[price.product_id].push(price);
      return acc;
    }, {});

    const priceComparisonMap = Object.keys(pricesByProduct).reduce((map, productId) => {
      const productPrices = pricesByProduct[productId];
      productPrices.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

      const latest = productPrices[0];
      const previous = productPrices.length > 1 ? productPrices[1] : null;

      map[productId] = {
        latest_price: latest ? latest.price : null,
        previous_price: previous ? previous.price : null,
        is_on_sale: latest ? latest.is_on_sale : false,
        store_name: latest ? latest.store_name : 'Unknown'
      };
      return map;
    }, {});

    // 4. Combine product info with price changes
    let deals = products.map(product => {
      const priceInfo = priceComparisonMap[product.id];
      if (!priceInfo || !priceInfo.latest_price) return null;

      let percentageChange = 0;
      let trend = 'same'; // 'up', 'down', 'same'

      if (priceInfo.previous_price && priceInfo.previous_price > 0) { // Avoid division by zero
        if (priceInfo.latest_price < priceInfo.previous_price) {
          percentageChange = ((priceInfo.previous_price - priceInfo.latest_price) / priceInfo.previous_price) * 100;
          trend = 'down';
        } else if (priceInfo.latest_price > priceInfo.previous_price) {
          percentageChange = ((priceInfo.latest_price - priceInfo.previous_price) / priceInfo.previous_price) * 100;
          trend = 'up';
        }
      }

      return {
        id: product.id,
        item: product.name,
        store: priceInfo.store_name || 'Unknown',
        price: priceInfo.latest_price,
        oldPrice: priceInfo.previous_price,
        percentage_change: percentageChange.toFixed(0),
        trend: trend,
        is_on_sale: priceInfo.is_on_sale,
        image_url: product.image_url,
        category: product.category,
      };
    }).filter(deal => deal !== null);

    // Sort by the highest percentage drop first, then by highest increase
    deals.sort((a, b) => {
        if (a.trend === 'down' && b.trend !== 'down') return -1;
        if (a.trend !== 'down' && b.trend === 'down') return 1;
        return b.percentage_change - a.percentage_change;
    });

    // 5. Apply limit
    const dealLimit = parseInt(limit, 10);
    if (dealLimit > 0) {
      deals = deals.slice(0, dealLimit);
    }

    res.json(deals);

  } catch (error) {
    console.error("Error aggregating deals:", error.message);
    res.status(500).json({ error: 'Failed to aggregate deals', details: error.message });
  }
});

// --- CATALOG PROXY ---
app.get('/categories', async (req, res) => {
  try {
    const response = await axios.get(`${CATALOG_URL}/categories`);
    res.json(response.data);
  } catch (error) {
    console.error("Error fetching categories:", error.message);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
});


app.listen(port, () => {
  console.log(`BFF Service listening on port ${port}`);
});
