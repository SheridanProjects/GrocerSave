-- 1. Create the Keyspace for the Price Service
CREATE KEYSPACE IF NOT EXISTS price_service
  WITH REPLICATION = {
    'class' : 'SimpleStrategy',
    'replication_factor' : 1
  };

-- 2. Switch to the new keyspace
USE price_service;

-- 3. Create the price_history table to EXACTLY match the CSV export
CREATE TABLE IF NOT EXISTS price_history (
    product_id UUID,
    recorded_at timestamp,
    is_on_sale boolean,
    price decimal,
    store_id UUID,
    PRIMARY KEY (product_id, recorded_at)
);

-- 4. Import the data using the exact column names from the header
COPY price_history (product_id, recorded_at, is_on_sale, price, store_id) FROM '/price_history.csv' WITH HEADER = true;