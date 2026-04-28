-- Execute each block in the matching database.

-- =========================
-- users_db_memorini
-- =========================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    hashed_password TEXT NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'client',
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- =========================
-- products_db_memorini
-- =========================
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    main_image TEXT NOT NULL,
    images TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    stock_mode VARCHAR(20) NOT NULL DEFAULT 'none'
      CHECK (stock_mode IN ('none', 'global', 'variant')),
    stock INTEGER CHECK (stock >= 0),
    variant_stock TEXT
);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);

-- =========================
-- orders_db_memorini
-- =========================
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(120) NOT NULL,
    phone1 VARCHAR(30) NOT NULL,
    phone2 VARCHAR(30),
    total_price NUMERIC(10,2) NOT NULL CHECK (total_price >= 0),
    items TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
      CHECK (status IN ('pending', 'confirmed', 'cancelled', 'shipping', 'delivered'))
);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- =========================
-- payments_db_memorini
-- =========================
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    method VARCHAR(50) NOT NULL DEFAULT 'cash_on_delivery',
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
      CHECK (status IN ('pending', 'confirmed', 'failed'))
);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
