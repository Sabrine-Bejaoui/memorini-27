from fastapi import FastAPI
from database import Base, engine
from routes.users import router as users_router
from routes.admin_users import router as admin_users_router

import time
from sqlalchemy.exc import OperationalError


for i in range(10):
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Connecté à la base de données")
        break
    except OperationalError:
        print(f"⏳ Base de données non prête, nouvelle tentative dans 3s ({i + 1}/10)...")
        time.sleep(3)
else:
    print("❌ Impossible de se connecter à la base de données.")


app = FastAPI(title="Memorini Users Service")

app.include_router(users_router)
app.include_router(admin_users_router)


@app.get("/")
def root():
    return {
        "service": "users_service",
        "status": "running"
    }