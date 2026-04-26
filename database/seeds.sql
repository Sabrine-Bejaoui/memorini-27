-- =========================
-- products_db_memorini
-- =========================
INSERT INTO products (name, category, description, price, main_image, images, is_active) VALUES
('Tirage Classique 10x15', 'Standard', 'Le tirage photo classique au format 10x15 cm, imprime sur papier premium.', 0.80, 'assets/images/products/standard_10x15.jpg', NULL, TRUE),
('Tirage Carre 15x15', 'Carre', 'Format carre moderne et tendance, ideal pour vos photos Instagram.', 1.50, 'assets/images/products/carre_15x15.jpg', NULL, TRUE),
('Pack Polaroid (x10)', 'Vintage', 'Donnez a vos souvenirs un air retro avec nos tirages style Polaroid.', 8.90, 'assets/images/products/polaroid_pack.jpg', NULL, TRUE),
('Poster Photo A2', 'Grand format', 'Sublimez votre interieur avec un poster grand format A2.', 24.00, 'assets/images/products/poster_a2.jpg', NULL, TRUE);

-- =========================
-- users_db_memorini
-- Use password "admin123" and "client123" with real bcrypt hashes
-- generated with users_service.auth.hash_password()
-- =========================
INSERT INTO users (full_name, email, phone, hashed_password, role, is_active) VALUES
('Admin Memorini', 'admin@memorini.tn', '+21600000000', '$2b$12$DX0Nl9RxgYNpU59vYklc1OOHQTaaCKebJNu87QPNv6KaeZsVt1H8e', 'admin', TRUE),
('Client Demo', 'client@memorini.tn', '+21611111111', '$2b$12$1hR.F4nQm4B1MmiWR/WyD.ZCEW7H/3Yhcz8uq697fhdr5LK93nZgG', 'client', TRUE);

-- =========================
-- orders_db_memorini
-- =========================
INSERT INTO orders (user_id, full_name, address, city, phone1, phone2, total_price, items, status) VALUES
(2, 'Client Demo', 'Rue des Jasmins, Lac 2', 'Tunis', '+21611111111', '+21622222222', 9.70,
 '[{"product_id":1,"name":"Tirage Classique 10x15","qty":1,"unit_price":0.80},{"product_id":3,"name":"Pack Polaroid (x10)","qty":1,"unit_price":8.90}]',
 'pending'),
(2, 'Client Demo', 'Avenue Habib Bourguiba', 'Sousse', '+21611111111', NULL, 24.00,
 '[{"product_id":4,"name":"Poster Photo A2","qty":1,"unit_price":24.00}]',
 'confirmed');

-- =========================
-- payments_db_memorini
-- =========================
INSERT INTO payments (order_id, user_id, amount, method, status) VALUES
(1, 2, 9.70, 'cash_on_delivery', 'pending'),
(2, 2, 24.00, 'cash_on_delivery', 'confirmed');
