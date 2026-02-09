-- Cassandra Seed Data
-- Service: Price Service
-- Context: High-volume write storage for price history

-- Create Keyspace
-- Using NetworkTopologyStrategy to match CASSANDRA_DC=datacenter1 from config
CREATE KEYSPACE IF NOT EXISTS price_service 
WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 1};

USE price_service;

-- Create Table
-- Partition Key: product_id (Groups all history for one product on one node)
-- Clustering Keys: store_id, recorded_at (Orders data within the partition)
CREATE TABLE IF NOT EXISTS price_history (
    product_id UUID,
    store_id UUID,
    recorded_at TIMESTAMP,
    price FLOAT,
    is_on_sale BOOLEAN,
    PRIMARY KEY ((product_id), store_id, recorded_at)
) WITH CLUSTERING ORDER BY (store_id ASC, recorded_at DESC);

-- Insert Prices for the 5 Products (Linked by UUIDs from Postgres)

-- 1. Milk (Regular Price)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES (a1b2c3d4-1111-2222-3333-444455556666, e4d60c4b-1234-5678-9012-f4d60c4b3333, toTimestamp(now()), 5.99, false);

-- 2. Bread (On Sale!)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES (a1b2c3d4-aaaa-bbbb-cccc-ddddeeeeffff, e4d60c4b-1234-5678-9012-f4d60c4b3333, toTimestamp(now()), 3.49, true);

-- 3. Eggs (Regular Price)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES (a1b2c3d4-9999-8888-7777-666655554444, e4d60c4b-1234-5678-9012-f4d60c4b3333, toTimestamp(now()), 4.50, false);

-- 4. Apples (Regular Price)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES (a1b2c3d4-cafe-babe-0000-111122223333, e4d60c4b-1234-5678-9012-f4d60c4b3333, toTimestamp(now()), 1.20, false);

-- 5. Almond Butter (Regular Price)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES (a1b2c3d4-d3ad-beef-aaaa-ccccddddeeee, e4d60c4b-1234-5678-9012-f4d60c4b3333, toTimestamp(now()), 8.99, false);

-- Insert a historical record for Milk (Old price from yesterday)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES (a1b2c3d4-1111-2222-3333-444455556666, e4d60c4b-1234-5678-9012-f4d60c4b3333, '1770513903000', 5.49, false);

