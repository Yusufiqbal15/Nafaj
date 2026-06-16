-- Add 'pending_confirmation' status to order_status enum
ALTER TABLE orders 
MODIFY COLUMN order_status ENUM(
  'pending', 
  'confirmed', 
  'preparing', 
  'ready', 
  'picked_up', 
  'out_for_delivery',
  'pending_confirmation', 
  'delivered', 
  'cancelled'
) DEFAULT 'pending';
