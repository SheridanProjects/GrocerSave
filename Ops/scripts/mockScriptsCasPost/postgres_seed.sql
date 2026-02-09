-- PostgreSQL Seed Data
-- Service: Catalog Service
-- Database: grocersave_db
-- Context: Stores Product metadata and Store info

-- Create Tables (Idempotent)
CREATE TABLE IF NOT EXISTS stores (
    store_id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    base_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS products (
    product_id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    image_url VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Store
INSERT INTO stores (store_id, name, base_url) VALUES
('e4d60c4b-1234-5678-9012-f4d60c4b3333', 'FreshMart Superstore', 'https://freshmart.example.com')
ON CONFLICT (store_id) DO NOTHING;

-- Insert 5 Products
INSERT INTO products (product_id, name, category, description, image_url, last_updated) VALUES
('a1b2c3d4-1111-2222-3333-444455556666', 'Organic Whole Milk', 'Dairy', 'Fresh organic whole milk from local farms.', 'http://images.example.com/milk.jpg', '2026-02-09 01:25:03'),
('a1b2c3d4-aaaa-bbbb-cccc-ddddeeeeffff', 'Artisan Sourdough Bread', 'Bakery', 'Freshly baked sourdough with a crispy crust.', 'http://images.example.com/bread.jpg', '2026-02-09 01:25:03'),
('a1b2c3d4-9999-8888-7777-666655554444', 'Free Range Eggs (Dozen)', 'Dairy', 'Large grade A free range eggs.', 'http://images.example.com/eggs.jpg', '2026-02-09 01:25:03'),
('a1b2c3d4-cafe-babe-0000-111122223333', 'Fuji Apples (1lb)', 'Produce', 'Sweet and crisp Fuji apples.', 'http://images.example.com/apples.jpg', '2026-02-09 01:25:03'),
('a1b2c3d4-d3ad-beef-aaaa-ccccddddeeee', 'Creamy Almond Butter', 'Pantry', 'All natural smooth almond butter.', 'http://images.example.com/almond_butter.jpg', '2026-02-09 01:25:03')
ON CONFLICT (product_id) DO NOTHING;

