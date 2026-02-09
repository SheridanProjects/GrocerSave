-- Drop the old table with the incorrect schema
DROP TABLE IF EXISTS products;

-- Create the new table with the correct UUID schema
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT
);

-- (Optional) You can add your INSERT statements here as well
-- to do everything in one step.

INSERT INTO products (name, description, image_url) VALUES
('Organic Milk', '2L of organic whole milk from a local farm.', 'https://images.unsplash.com/photo-1559598467-f8b76c8155d0'),
('Free-Range Eggs', 'One dozen large brown free-range eggs.', 'https://images.unsplash.com/photo-1587613794025-91c449b4414c'),
('Sourdough Bread', 'Freshly baked artisan sourdough loaf.', 'https://images.unsplash.com/photo-1533782492-52432b260845'),
('Avocados', 'Bag of 5 ripe Hass avocados.', 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578'),
('Chicken Breast', '1kg of skinless, boneless chicken breast.', 'https://images.unsplash.com/photo-1604503468825-a74a72de9044');
