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

app.get('/health', (req, res) => {
  res.json({ status: 'UP', service: 'bff-service' });
});

app.get('/api/deals', async (req, res) => {
  // In a real scenario, this would aggregate data from catalog and price services
  // For now, we return mock data similar to what the frontend expects
  const mockDeals = [
    { id: 1, item: "Organic Milk 2L", store: "SuperStore", price: 4.99, oldPrice: 6.50, drop: "23%" },
    { id: 2, item: "Free Range Eggs (12)", store: "FreshMart", price: 3.49, oldPrice: 5.00, drop: "30%" },
    { id: 3, item: "Avocados (Bag of 5)", store: "VeggieCity", price: 2.99, oldPrice: 4.99, drop: "40%" },
    { id: 4, item: "Sourdough Bread", store: "BakeryBarn", price: 3.25, oldPrice: 4.50, drop: "27%" },
  ];
  res.json(mockDeals);
});

app.listen(port, () => {
  console.log(`BFF Service listening on port ${port}`);
});