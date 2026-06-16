-- Add tracking image fields to orders table
ALTER TABLE orders
ADD COLUMN pickup_image_url VARCHAR(500) DEFAULT NULL AFTER delivery_longitude,
ADD COLUMN delivery_image_url VARCHAR(500) DEFAULT NULL AFTER pickup_image_url,
ADD COLUMN pickup_timestamp TIMESTAMP NULL DEFAULT NULL AFTER delivery_image_url,
ADD COLUMN delivery_timestamp TIMESTAMP NULL DEFAULT NULL AFTER pickup_timestamp;

-- Add index for better query performance
ALTER TABLE orders
ADD INDEX idx_pickup_timestamp (pickup_timestamp),
ADD INDEX idx_delivery_timestamp (delivery_timestamp);
