# Memorini - Setup and Run

## 1) Prerequisites

- Docker Desktop (recommended)
- OR PostgreSQL + Python 3.11 + Flutter SDK

## 2) Database setup (pgAdmin)

Create the 4 databases:

```sql
CREATE DATABASE users_db_memorini;
CREATE DATABASE products_db_memorini;
CREATE DATABASE orders_db_memorini;
CREATE DATABASE payments_db_memorini;
```

Then run:

- `database/schema.sql` (table creation)
- `database/seeds.sql` (initial data)

## 3) Run with Docker (recommended)

From project root:

```bash
docker compose up --build
```

Services:

- API Gateway: `http://localhost:8000`
- Users: `http://localhost:8001`
- Products: `http://localhost:8002`
- Orders: `http://localhost:8003`
- Payments: `http://localhost:8004`

Databases:

- users DB: `localhost:5433`
- products DB: `localhost:5434`
- orders DB: `localhost:5435`
- payments DB: `localhost:5436`

## 4) Run backend locally without Docker

Ensure `.env` exists at root.

Open 5 terminals:

```bash
# terminal 1
cd users_service
pip install -r requirements.txt
uvicorn main:app --reload --port 8001

# terminal 2
cd products_service
pip install -r requirements.txt
uvicorn main:app --reload --port 8002

# terminal 3
cd orders_service
pip install -r requirements.txt
uvicorn main:app --reload --port 8003

# terminal 4
cd payments_service
pip install -r requirements.txt
uvicorn main:app --reload --port 8004

# terminal 5
cd api_gateway
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

## 5) Run Flutter frontend

```bash
cd memorini_frontend
flutter pub get
flutter run -d chrome
```

If you need a custom API host:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Android emulator example:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## 6) Demo accounts from seed

- Admin: `admin@memorini.tn` / `admin123`
- Client: `client@memorini.tn` / `client123`