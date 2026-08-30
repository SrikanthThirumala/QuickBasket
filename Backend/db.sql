DROP DATABASE IF EXISTS quickbasket_db;
CREATE DATABASE quickbasket_db;
USE quickbasket_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    default_address TEXT,
    role VARCHAR(20) DEFAULT 'user',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    image_url VARCHAR(1000),
    category VARCHAR(100) DEFAULT 'General',
    unit VARCHAR(50) DEFAULT 'each',
    stock_quantity INT DEFAULT 0,
    calories INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE promocodes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_percent INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    total_calories INT DEFAULT 0,
    delivery_address TEXT NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'Card',
    promo_code VARCHAR(50),
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE otp_verifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(120) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data in INR and with calories
INSERT INTO products (name, price, image_url, category, unit, stock_quantity, calories, is_active) VALUES 
('Organic Fresh Bananas', 120.00, 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=500', 'Produce', '1 bunch', 120, 105, TRUE),
('Fresh Hass Avocados', 330.00, 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500', 'Produce', '3 pack', 85, 240, TRUE),
('Whole Farm Milk', 320.00, 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500', 'Dairy', '1 Liter', 45, 150, TRUE),
('Artisan Sourdough Loaf', 370.00, 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=500', 'Bakery', 'loaf', 30, 290, TRUE),
('Grass-Fed Ribeye Steak', 1240.00, 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=500', 'Meat & Seafood', '12 oz', 25, 600, TRUE),
('Farm Fresh Eggs', 180.00, 'https://images.unsplash.com/photo-1587486913049-53fc88980cfc?w=500', 'Dairy', '1 Dozen', 100, 70, TRUE);

INSERT INTO promocodes (code, discount_percent) VALUES ('QUICKFRESH', 15), ('WELCOME10', 10);