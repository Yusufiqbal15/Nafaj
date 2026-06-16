CREATE TABLE IF NOT EXISTS categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon VARCHAR(500),
  status ENUM('active', 'inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_name (name),
  INDEX idx_status (status)
);

-- Insert default categories
INSERT IGNORE INTO categories (id, name, description) VALUES
(1, 'Delivery', 'Delivery services'),
(2, 'Rides', 'Ride sharing services'),
(3, 'Logistics', 'Logistics and transport'),
(4, 'Errands', 'Quick errands and tasks'),
(5, 'Moving', 'Moving and relocation services');
