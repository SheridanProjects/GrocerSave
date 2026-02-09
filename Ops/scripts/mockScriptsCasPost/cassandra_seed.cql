-- It's often better to let the price-service create the table,
-- but for manual seeding, you would run this after the table is created.
-- This script assumes the price_history table has been created with the correct schema:
-- CREATE TABLE price_service.price_history (
--   product_id UUID,
--   store_id UUID,
--   price DECIMAL,
--   is_on_sale BOOLEAN,
--   recorded_at TIMESTAMP,
--   PRIMARY KEY (product_id, recorded_at)
-- );

-- Use the correct keyspace
USE price_service;

-- Clear existing data
TRUNCATE price_history;

-- Insert new price data using the EXACT UUIDs from the PostgreSQL products table
-- Product: Organic Milk (d02a9637-aa96-48a2-8a21-98c01e2c0490)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (d02a9637-aa96-48a2-8a21-98c01e2c0490, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (d02a9637-aa96-48a2-8a21-98c01e2c0490, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.79, true, toTimestamp(now()) - 1d);

-- Product: Free-Range Eggs (696c8a34-c1b2-4cde-937a-b4ddd95bc649)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (696c8a34-c1b2-4cde-937a-b4ddd95bc649, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.49, false, toTimestamp(now()));

-- Product: Sourdough Bread (eefae3e5-26d0-470c-8663-fe92cc77d871)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (eefae3e5-26d0-470c-8663-fe92cc77d871, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.99, true, toTimestamp(now()));

-- Product: Avocados (b7d0ee9d-5289-407f-9ded-89edeb8d7cdf)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (b7d0ee9d-5289-407f-9ded-89edeb8d7cdf, e4d60c4b-1234-5678-9012-f4d60c4b3333, 6.00, false, toTimestamp(now()));

-- Product: Chicken Breast (e23b3640-a2c5-4500-b850-4e5bb38de081)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (e23b3640-a2c5-4500-b850-4e5bb38de081, e4d60c4b-1234-5678-9012-f4d60c4b3333, 12.50, false, toTimestamp(now()));
