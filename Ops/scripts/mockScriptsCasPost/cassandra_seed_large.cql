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
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (d02a9637-aa96-48a2-8a21-98c01e2c0490, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.89, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (d02a9637-aa96-48a2-8a21-98c01e2c0490, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.99, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (d02a9637-aa96-48a2-8a21-98c01e2c0490, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.69, true, toTimestamp(now()) - 4d);

-- Product: Free-Range Eggs (696c8a34-c1b2-4cde-937a-b4ddd95bc649)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (696c8a34-c1b2-4cde-937a-b4ddd95bc649, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.49, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (696c8a34-c1b2-4cde-937a-b4ddd95bc649, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.29, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (696c8a34-c1b2-4cde-937a-b4ddd95bc649, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.39, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (696c8a34-c1b2-4cde-937a-b4ddd95bc649, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.49, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (696c8a34-c1b2-4cde-937a-b4ddd95bc649, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.19, true, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (696c8a34-c1b2-4cde-937a-b4ddd95bc649, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.09, true, toTimestamp(now()) - 5d);

-- Product: Sourdough Bread (eefae3e5-26d0-470c-8663-fe92cc77d871)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (eefae3e5-26d0-470c-8663-fe92cc77d871, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.99, true, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (eefae3e5-26d0-470c-8663-fe92cc77d871, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.19, false, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (eefae3e5-26d0-470c-8663-fe92cc77d871, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.09, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (eefae3e5-26d0-470c-8663-fe92cc77d871, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.89, true, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (eefae3e5-26d0-470c-8663-fe92cc77d871, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.99, false, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (eefae3e5-26d0-470c-8663-fe92cc77d871, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.29, false, toTimestamp(now()) - 5d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (eefae3e5-26d0-470c-8663-fe92cc77d871, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.09, true, toTimestamp(now()) - 6d);

-- Product: Avocados (b7d0ee9d-5289-407f-9ded-89edeb8d7cdf)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (b7d0ee9d-5289-407f-9ded-89edeb8d7cdf, e4d60c4b-1234-5678-9012-f4d60c4b3333, 6.00, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (b7d0ee9d-5289-407f-9ded-89edeb8d7cdf, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.80, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (b7d0ee9d-5289-407f-9ded-89edeb8d7cdf, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.90, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (b7d0ee9d-5289-407f-9ded-89edeb8d7cdf, e4d60c4b-1234-5678-9012-f4d60c4b3333, 6.10, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (b7d0ee9d-5289-407f-9ded-89edeb8d7cdf, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.70, true, toTimestamp(now()) - 4d);

-- Product: Chicken Breast (e23b3640-a2c5-4500-b850-4e5bb38de081)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (e23b3640-a2c5-4500-b850-4e5bb38de081, e4d60c4b-1234-5678-9012-f4d60c4b3333, 12.50, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (e23b3640-a2c5-4500-b850-4e5bb38de081, e4d60c4b-1234-5678-9012-f4d60c4b3333, 12.00, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (e23b3640-a2c5-4500-b850-4e5bb38de081, e4d60c4b-1234-5678-9012-f4d60c4b3333, 12.25, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (e23b3640-a2c5-4500-b850-4e5bb38de081, e4d60c4b-1234-5678-9012-f4d60c4b3333, 12.75, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (e23b3640-a2c5-4500-b850-4e5bb38de081, e4d60c4b-1234-5678-9012-f4d60c4b3333, 11.50, true, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (e23b3640-a2c5-4500-b850-4e5bb38de081, e4d60c4b-1234-5678-9012-f4d60c4b3333, 11.75, true, toTimestamp(now()) - 5d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (e23b3640-a2c5-4500-b850-4e5bb38de081, e4d60c4b-1234-5678-9012-f4d60c4b3333, 12.00, false, toTimestamp(now()) - 6d);

-- Product: Salmon Fillet (9f8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9f8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 15.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9f8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 14.50, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9f8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 15.99, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9f8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 16.50, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9f8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 14.20, true, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9f8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 15.99, false, toTimestamp(now()) - 5d);

-- Product: Organic Apples (1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.50, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.50, false, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.99, true, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.99, true, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.25, false, toTimestamp(now()) - 4d);

-- Product: Greek Yogurt (2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.49, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.99, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.49, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.49, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.29, false, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.99, true, toTimestamp(now()) - 5d);

-- Product: Quinoa (3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 6.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 6.49, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 6.99, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 7.29, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 6.99, false, toTimestamp(now()) - 4d);

-- Product: Almond Milk (4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.50, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.99, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.10, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.75, true, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.99, false, toTimestamp(now()) - 5d);

-- Product: Organic Carrots (5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.99, false, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.50, true, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.99, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.15, false, toTimestamp(now()) - 4d);

-- Product: Whole Wheat Pasta (6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.49, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.00, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.49, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.49, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.99, true, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.25, false, toTimestamp(now()) - 5d);

-- Product: Cheddar Cheese (7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.99, false, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 5.25, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.50, true, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.99, false, toTimestamp(now()) - 4d);

-- Product: Tomatoes (8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.50, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.20, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.50, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.80, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.50, false, toTimestamp(now()) - 4d);

-- Product: Ground Beef (9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 8.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 8.50, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 8.99, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 9.50, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 8.00, true, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f, e4d60c4b-1234-5678-9012-f4d60c4b3333, 8.99, false, toTimestamp(now()) - 5d);

-- Product: Bananas (0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.49, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.49, false, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.20, true, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.49, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a, e4d60c4b-1234-5678-9012-f4d60c4b3333, 1.60, false, toTimestamp(now()) - 4d);

-- Product: Spinach (1e2f3a4b-5c6d-7e8f-9a0b-1c2d3e4f5a6b)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1e2f3a4b-5c6d-7e8f-9a0b-1c2d3e4f5a6b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1e2f3a4b-5c6d-7e8f-9a0b-1c2d3e4f5a6b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.50, true, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1e2f3a4b-5c6d-7e8f-9a0b-1c2d3e4f5a6b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.99, false, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1e2f3a4b-5c6d-7e8f-9a0b-1c2d3e4f5a6b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.25, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1e2f3a4b-5c6d-7e8f-9a0b-1c2d3e4f5a6b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.99, false, toTimestamp(now()) - 4d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (1e2f3a4b-5c6d-7e8f-9a0b-1c2d3e4f5a6b, e4d60c4b-1234-5678-9012-f4d60c4b3333, 2.75, true, toTimestamp(now()) - 5d);

-- Product: Oats (2f3a4b5c-6d7e-8f9a-0b1c-2d3e4f5a6b7c)
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2f3a4b5c-6d7e-8f9a-0b1c-2d3e4f5a6b7c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.99, false, toTimestamp(now()));
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2f3a4b5c-6d7e-8f9a-0b1c-2d3e4f5a6b7c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.99, false, toTimestamp(now()) - 1d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2f3a4b5c-6d7e-8f9a-0b1c-2d3e4f5a6b7c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.50, true, toTimestamp(now()) - 2d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2f3a4b5c-6d7e-8f9a-0b1c-2d3e4f5a6b7c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 3.99, false, toTimestamp(now()) - 3d);
INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (2f3a4b5c-6d7e-8f9a-0b1c-2d3e4f5a6b7c, e4d60c4b-1234-5678-9012-f4d60c4b3333, 4.25, false, toTimestamp(now()) - 4d);