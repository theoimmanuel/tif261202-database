-- ============================================================================
-- FINAL PROJECT: RELATIONAL DATABASE DESIGN & DATA INTEGRATION
-- Database Management Systems - PostgreSQL
-- Focus: Schema Design, DDL, DML, Data Cleansing, and DQL (No Views/Triggers)
-- ============================================================================

-- Clean up existing tables
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

DROP TABLE IF EXISTS staging_customers_csv CASCADE;
DROP TABLE IF EXISTS staging_transactions_json CASCADE;

-- ============================================================================
-- 1. STAGING TABLES (For Raw Ingestion via GUI / COPY)
-- ============================================================================

CREATE TABLE staging_customers_csv (
    raw_customer_id TEXT,
    raw_name TEXT,
    raw_email TEXT,
    raw_phone TEXT,
    raw_city TEXT,
    raw_registered_date TEXT
);

CREATE TABLE staging_transactions_json (
    payload JSONB NOT NULL,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. CORE RELATIONAL TABLES (Normalized OLTP Schema)
-- ============================================================================

CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES categories(category_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    product_name VARCHAR(150) NOT NULL UNIQUE,
    sku VARCHAR(50) NOT NULL UNIQUE,
    base_price NUMERIC(12,2) NOT NULL CHECK (base_price > 0)
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_code VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30),
    city VARCHAR(100) NOT NULL DEFAULT 'Unknown',
    registered_date DATE NOT NULL
);

CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
    order_code VARCHAR(50) NOT NULL UNIQUE,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    store_id INT NOT NULL REFERENCES stores(store_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    payment_method VARCHAR(50) NOT NULL
);

CREATE TABLE order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
    subtotal NUMERIC(14,2) NOT NULL CHECK (subtotal > 0),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id)
);

-- ============================================================================
-- 3. SEED MASTER DATA (Reference Tables)
-- ============================================================================

INSERT INTO stores (store_name, city, state_province) VALUES
('Jakarta Flagship', 'Jakarta', 'DKI Jakarta'),
('Bandung Digital Hub', 'Bandung', 'West Java'),
('Surabaya Megastore', 'Surabaya', 'East Java'),
('Yogyakarta Creative Outlet', 'Yogyakarta', 'DI Yogyakarta'),
('Medan Central', 'Medan', 'North Sumatra');

INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Devices, gadgets, peripherals, and accessories'),
('Home & Kitchen', 'Appliances, cookware, and daily essentials'),
('Apparel & Fashion', 'Clothing, footwear, and wearable items'),
('Sports & Fitness', 'Outdoor equipment, athletic gear, and wellness'),
('Books & Stationery', 'Office supplies, notebooks, and reading material');

INSERT INTO products (category_id, product_name, sku, base_price) VALUES
(1, 'Ergonomic Mechanical Keyboard', 'ELEC-KB-001', 1250000.00),
(1, 'Wireless Precision Mouse', 'ELEC-MS-002', 450000.00),
(1, '27-inch 4K IPS Monitor', 'ELEC-MN-003', 4200000.00),
(1, 'Active Noise-Cancelling Headphones', 'ELEC-HP-004', 1850000.00),
(1, 'USB-C Multiport Docking Station', 'ELEC-DK-005', 750000.00),
(2, 'Smart Electric Kettle 1.5L', 'HOME-KT-001', 380000.00),
(2, 'Espresso Coffee Grinder Pro', 'HOME-CG-002', 1150000.00),
(2, 'Air Fryer Digital 4L', 'HOME-AF-003', 950000.00),
(3, 'Quick-Dry Athletic T-Shirt', 'FASH-TS-001', 180000.00),
(3, 'Water-Resistant Commuter Jacket', 'FASH-JK-002', 650000.00),
(3, 'Urban Casual Sneakers', 'FASH-SN-003', 890000.00),
(4, 'High-Density Non-Slip Yoga Mat', 'SPRT-YM-001', 250000.00),
(4, 'Adjustable Hex Dumbbell Pair (10kg)', 'SPRT-DB-002', 520000.00),
(4, 'Speed Jump Rope Steel Cable', 'SPRT-JR-003', 95000.00),
(5, 'Dot Grid Hardcover Journal A5', 'STAT-JN-001', 85000.00),
(5, 'Archival Rollerball Pen Set (Pack of 5)', 'STAT-PN-002', 120000.00),
(5, 'Minimalist Aluminum Laptop Stand', 'STAT-LS-003', 310000.00);
