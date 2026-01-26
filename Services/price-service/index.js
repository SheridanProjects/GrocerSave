const express = require('express');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 8182;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'UP', service: 'price-service' });
});

app.listen(port, () => {
  console.log(`Price Service listening on port ${port}`);
});