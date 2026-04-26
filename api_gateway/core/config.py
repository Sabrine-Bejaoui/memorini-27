import os

USERS_SERVICE_URL = os.getenv("USERS_SERVICE_URL", "http://users_service:8001")
PRODUCTS_SERVICE_URL = os.getenv("PRODUCTS_SERVICE_URL", "http://products_service:8002")
ORDERS_SERVICE_URL = os.getenv("ORDERS_SERVICE_URL", "http://orders_service:8003")
PAYMENTS_SERVICE_URL = os.getenv("PAYMENTS_SERVICE_URL", "http://payments_service:8004")