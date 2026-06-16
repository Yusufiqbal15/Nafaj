-- Fix order_status ENUM to include all needed statuses
ALTER TABLE orders
MODIFY COLUMN order_status ENUM(
  'pending_vendor_confirmation',
  'vendor_confirmed',
  'driver_assigned',
  'pending',
  'confirmed',
  'preparing',
  'ready',
  'picked_up',
  'out_for_delivery',
  'delivering',
  'pending_confirmation',
  'delivered',
  'cancelled'
) DEFAULT 'pending_vendor_confirmation';

-- Add vendor_confirmed_at if not exists (ignore error if already there)
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'vendor_confirmed_at'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE orders ADD COLUMN vendor_confirmed_at TIMESTAMP NULL DEFAULT NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Add driver_accepted_at if not exists
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'driver_accepted_at'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE orders ADD COLUMN driver_accepted_at TIMESTAMP NULL DEFAULT NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Add wallet_balance to drivers if not exists
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'drivers' AND COLUMN_NAME = 'wallet_balance'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE drivers ADD COLUMN wallet_balance DECIMAL(10,2) NOT NULL DEFAULT 0.00',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Add total_earnings to drivers if not exists
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'drivers' AND COLUMN_NAME = 'total_earnings'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE drivers ADD COLUMN total_earnings DECIMAL(10,2) NOT NULL DEFAULT 0.00',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Driver wallet transactions table
CREATE TABLE IF NOT EXISTS driver_wallet_transactions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  driver_id INT NOT NULL,
  order_id INT DEFAULT NULL,
  order_number VARCHAR(50) DEFAULT NULL,
  transaction_type ENUM('delivery_fee', 'bonus', 'withdrawal', 'adjustment') DEFAULT 'delivery_fee',
  amount DECIMAL(10,2) NOT NULL,
  description VARCHAR(255),
  balance_after DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (driver_id) REFERENCES drivers(id),
  INDEX idx_driver_id (driver_id),
  INDEX idx_order_id (order_id),
  INDEX idx_created_at (created_at)
);

-- Backfill: create wallet transactions for all past delivered orders that have no record yet
INSERT INTO driver_wallet_transactions (driver_id, order_id, order_number, transaction_type, amount, description, balance_after, created_at)
SELECT
  o.driver_id,
  o.id,
  o.order_number,
  'delivery_fee',
  500.00,
  CONCAT('Delivery fee — order ', o.order_number),
  (SELECT COUNT(*) FROM orders o2
   WHERE o2.order_status = 'delivered' AND o2.driver_id = o.driver_id AND o2.id <= o.id) * 500.00,
  COALESCE(o.updated_at, o.created_at)
FROM orders o
WHERE o.order_status = 'delivered'
  AND o.driver_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM driver_wallet_transactions dwt
    WHERE dwt.order_id = o.id AND dwt.driver_id = o.driver_id
  )
ORDER BY o.driver_id, o.id;

-- Update driver wallet_balance and total_earnings from actual transaction sum
UPDATE drivers d
SET
  wallet_balance = COALESCE((SELECT SUM(amount) FROM driver_wallet_transactions WHERE driver_id = d.id), 0),
  total_earnings = COALESCE((SELECT SUM(amount) FROM driver_wallet_transactions WHERE driver_id = d.id), 0)
WHERE EXISTS (SELECT 1 FROM orders WHERE driver_id = d.id AND order_status = 'delivered');
