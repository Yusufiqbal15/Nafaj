-- Vendor confirmation workflow migration
-- Adds new statuses and timestamp columns for vendor confirm / driver assign flow

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
  'pending_confirmation',
  'delivered',
  'cancelled'
) DEFAULT 'pending_vendor_confirmation';

ALTER TABLE orders
ADD COLUMN IF NOT EXISTS vendor_confirmed_at TIMESTAMP NULL DEFAULT NULL AFTER updated_at,
ADD COLUMN IF NOT EXISTS driver_accepted_at TIMESTAMP NULL DEFAULT NULL AFTER vendor_confirmed_at;
