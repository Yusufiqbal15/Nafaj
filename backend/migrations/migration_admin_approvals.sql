-- Admin approvals audit log table
-- The actual approval status is stored in the vendors.status and drivers.status columns:
--   vendors:  pending_approval / active / suspended
--   drivers:  pending_verification / active / suspended
-- This table records who approved/rejected and when.

CREATE TABLE IF NOT EXISTS admin_approvals (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_type ENUM('vendor', 'driver') NOT NULL,
  user_id INT NOT NULL,
  action ENUM('approved', 'rejected') NOT NULL,
  notes TEXT,
  acted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user (user_type, user_id)
);
