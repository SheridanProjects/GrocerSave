#!/bin/bash

# -----------------------------------------------------------------------------
# Configuration & UUID Generation
# -----------------------------------------------------------------------------

# Postgres Config (Updated from k8s spec)
PG_USER="grocer_admin"
PG_DB="grocersave_db"

# Cassandra Config
CASSANDRA_DC="datacenter1"

# We define fixed UUIDs to ensure the Foreign Keys in Cassandra (price_history)
# match the Primary Keys in Postgres (products).

STORE_ID="e4d60c4b-1234-5678-9012-f4d60c4b3333"

# Product IDs
PROD_1_ID="a1b2c3d4-1111-2222-3333-444455556666" # Organic Whole Milk
PROD_2_ID="a1b2c3d4-aaaa-bbbb-cccc-ddddeeeeffff" # Sourdough Bread
PROD_3_ID="a1b2c3d4-9999-8888-7777-666655554444" # Free Range Eggs
PROD_4_ID="a1b2c3d4-cafe-babe-0000-111122223333" # Fuji Apples
PROD_5_ID="a1b2c3d4-d3ad-beef-aaaa-ccccddddeeee" # Almond Butter

# Timestamps
NOW=$(date -u +"%Y-%m-%d %H:%M:%S")
NOW_TS=$(date +%s)000 # Milliseconds for Cassandra

echo "Generating database seed files..."

# -----------------------------------------------------------------------------
# 1. Generate PostgreSQL Seed File (Catalog Service)
# -----------------------------------------------------------------------------
cat > postgres_seed.sql <<EOF
-- PostgreSQL Seed Data
-- Service: Catalog Service
-- Database: $PG_DB
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
('$STORE_ID', 'FreshMart Superstore', 'https://freshmart.example.com')
ON CONFLICT (store_id) DO NOTHING;

-- Insert 5 Products
INSERT INTO products (product_id, name, category, description, image_url, last_updated) VALUES
('$PROD_1_ID', 'Organic Whole Milk', 'Dairy', 'Fresh organic whole milk from local farms.', 'http://images.example.com/milk.jpg', '$NOW'),
('$PROD_2_ID', 'Artisan Sourdough Bread', 'Bakery', 'Freshly baked sourdough with a crispy crust.', 'http://images.example.com/bread.jpg', '$NOW'),
('$PROD_3_ID', 'Free Range Eggs (Dozen)', 'Dairy', 'Large grade A free range eggs.', 'http://images.example.com/eggs.jpg', '$NOW'),
('$PROD_4_ID', 'Fuji Apples (1lb)', 'Produce', 'Sweet and crisp Fuji apples.', 'http://images.example.com/apples.jpg', '$NOW'),
('$PROD_5_ID', 'Creamy Almond Butter', 'Pantry', 'All natural smooth almond butter.', 'http://images.example.com/almond_butter.jpg', '$NOW')
ON CONFLICT (product_id) DO NOTHING;

EOF

echo "✅ Created postgres_seed.sql"

# -----------------------------------------------------------------------------
# 2. Generate Cassandra Seed File (Price Service)
# -----------------------------------------------------------------------------
cat > cassandra_seed.cql <<EOF
-- Cassandra Seed Data
-- Service: Price Service
-- Context: High-volume write storage for price history

-- Create Keyspace
-- Using NetworkTopologyStrategy to match CASSANDRA_DC=$CASSANDRA_DC from config
CREATE KEYSPACE IF NOT EXISTS price_service 
WITH replication = {'class': 'NetworkTopologyStrategy', '$CASSANDRA_DC': 1};

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
VALUES ($PROD_1_ID, $STORE_ID, toTimestamp(now()), 5.99, false);

-- 2. Bread (On Sale!)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES ($PROD_2_ID, $STORE_ID, toTimestamp(now()), 3.49, true);

-- 3. Eggs (Regular Price)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES ($PROD_3_ID, $STORE_ID, toTimestamp(now()), 4.50, false);

-- 4. Apples (Regular Price)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES ($PROD_4_ID, $STORE_ID, toTimestamp(now()), 1.20, false);

-- 5. Almond Butter (Regular Price)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES ($PROD_5_ID, $STORE_ID, toTimestamp(now()), 8.99, false);

-- Insert a historical record for Milk (Old price from yesterday)
INSERT INTO price_history (product_id, store_id, recorded_at, price, is_on_sale)
VALUES ($PROD_1_ID, $STORE_ID, '$((NOW_TS - 86400000))', 5.49, false);

EOF

echo "✅ Created cassandra_seed.cql"

echo ""
echo "1. Load Postgres Data (Catalog Service):"
echo "   cat postgres_seed.sql | kubectl exec -n $K8S_NAMESPACE -i <postgres_pod_name> -- psql -U $PG_USER -d $PG_DB"
echo ""
echo "2. Load Cassandra Data (Price Service):"
echo "   cat cassandra_seed.cql | kubectl exec -n $K8S_NAMESPACE -i <cassandra_pod_name> -- cqlsh"
echo ""
echo "----------------------------------------------------------------"
echo "To VERIFY/DUMP the data after loading:"
echo "----------------------------------------------------------------"
echo ""
echo "3. Dump Postgres Products:"
echo "   kubectl exec -n $K8S_NAMESPACE -i <postgres_pod_name> -- psql -U $PG_USER -d $PG_DB -c \"SELECT * FROM products;\""
echo ""
echo "4. Dump Cassandra Prices:"
echo "   kubectl exec -n $K8S_NAMESPACE -i <cassandra_pod_name> -- cqlsh -e \"SELECT * FROM price_service.price_history;\""
echo ""
echo "----------------------------------------------------------------"
