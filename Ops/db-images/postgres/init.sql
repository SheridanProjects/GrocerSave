-- This script will be executed automatically when the PostgreSQL container starts for the first time.
-- Add your CREATE TABLE statements, INSERT statements, and other setup commands here.

-- Example:
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username) VALUES ('initial_user') ON CONFLICT (username) DO NOTHING;
