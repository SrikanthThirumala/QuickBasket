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

INSERT INTO products (name, price, image_url, category, unit, stock_quantity, calories) VALUES 
-- Produce
('Organic Bananas', 60.00, 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400', 'Produce', '1 bunch', 100, 105),
('Hass Avocados', 300.00, 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400', 'Produce', '3 pack', 100, 240),
('Red Apples', 180.00, 'https://images.unsplash.com/photo-1560806887-1e4cd0b6fac6?w=400', 'Produce', '1 kg', 100, 95),
('Fresh Spinach', 45.00, 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400', 'Produce', '1 bunch', 100, 23),
('Carrots', 50.00, 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400', 'Produce', '1 kg', 100, 41),
('Tomatoes', 40.00, 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400', 'Produce', '1 kg', 100, 22),
('Green Bell Peppers', 60.00, 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400', 'Produce', '500g', 100, 24),
('Onions', 35.00, 'https://images.unsplash.com/photo-1620574387735-3624d75b2dbc?w=400', 'Produce', '1 kg', 100, 40),
('Garlic', 80.00, 'https://images.unsplash.com/photo-1540148426945-6667d44d07cd?w=400', 'Produce', '250g', 100, 149),
('Potatoes', 40.00, 'https://images.unsplash.com/photo-1518977622811-653f2c35a822?w=400', 'Produce', '1 kg', 100, 77),
-- Dairy & Eggs
('Whole Milk', 65.00, 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400', 'Dairy', '1 Liter', 100, 150),
('Farm Eggs', 90.00, 'https://images.unsplash.com/photo-1587486913049-53fc88980cfc?w=400', 'Dairy', '1 Dozen', 100, 70),
('Cheddar Cheese', 250.00, 'https://images.unsplash.com/photo-1618164436241-4473940d1f5c?w=400', 'Dairy', '200g', 100, 402),
('Greek Yogurt', 120.00, 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400', 'Dairy', '500g', 100, 59),
('Salted Butter', 110.00, 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400', 'Dairy', '200g', 100, 717),
('Paneer', 140.00, 'https://images.unsplash.com/photo-1631452180519-c014fe946bc0?w=400', 'Dairy', '200g', 100, 265),
-- Bakery
('Sourdough Loaf', 150.00, 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=400', 'Bakery', '1 Loaf', 100, 290),
('Croissants', 200.00, 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400', 'Bakery', '4 pack', 100, 231),
('Baguette', 120.00, 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400', 'Bakery', '1 Loaf', 100, 240),
('Chocolate Muffins', 180.00, 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400', 'Bakery', '2 pack', 100, 377),
-- Meat
('Chicken Breast', 350.00, 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400', 'Meat', '500g', 100, 165),
('Mutton Mince', 650.00, 'https://images.unsplash.com/photo-1588168333986-50845fce0ba9?w=400', 'Meat', '500g', 100, 250),
('Salmon Fillet', 950.00, 'https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?w=400', 'Meat', '250g', 100, 208),
('Prawns', 550.00, 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400', 'Meat', '500g', 100, 99),
-- Snacks
('Potato Chips', 50.00, 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400', 'Snacks', '150g', 100, 536),
('Almonds', 450.00, 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400', 'Snacks', '500g', 100, 579),
('Dark Chocolate', 150.00, 'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=400', 'Snacks', '100g', 100, 546),
('Protein Bar', 80.00, 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400', 'Snacks', '1 Bar', 100, 200),
('Mixed Nuts', 350.00, 'https://images.unsplash.com/photo-1536591375315-bb8266497f25?w=400', 'Snacks', '250g', 100, 607),
('Popcorn', 40.00, 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400', 'Snacks', '100g', 100, 387),
-- Beverages
('Orange Juice', 120.00, 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400', 'Beverages', '1 Liter', 100, 45),
('Green Tea', 150.00, 'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?w=400', 'Beverages', '25 Bags', 100, 2),
('Coffee Beans', 400.00, 'https://images.unsplash.com/photo-1559525839-b184a4d698c7?w=400', 'Beverages', '250g', 100, 5),
('Sparkling Water', 60.00, 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400', 'Beverages', '1 Liter', 100, 0),
('Cola', 40.00, 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400', 'Beverages', '500ml', 100, 140),
-- Pantry
('Olive Oil', 750.00, 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400', 'Pantry', '1 Liter', 100, 884),
('Basmati Rice', 220.00, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400', 'Pantry', '1 kg', 100, 130),
('Pasta', 90.00, 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400', 'Pantry', '500g', 100, 131),
('Tomato Ketchup', 110.00, 'https://images.unsplash.com/photo-1577905891109-b6b907577d4b?w=400', 'Pantry', '500g', 100, 101),
('Honey', 300.00, 'https://images.unsplash.com/photo-1587049352847-81a56d773c1c?w=400', 'Pantry', '250g', 100, 304);

INSERT INTO promocodes (code, discount_percent) VALUES ('QUICKFRESH', 15), ('WELCOME10', 10);

-- UPDATE users SET role = 'admin' WHERE email = 'sanjay@sanjay.com';