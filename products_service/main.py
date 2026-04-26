from fastapi import FastAPI
from database import Base, engine
from routes.products import router as products_router

import time
from sqlalchemy.exc import OperationalError

for i in range(10):
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Connecté à la base de données")
        break
    except OperationalError as e:
        print(f"⏳ Base de données non prête, nouvelle tentative dans 3s ({i+1}/10)...")
        time.sleep(3)
else:
    print("❌ Impossible de se connecter à la base de données.")


app = FastAPI(title="Memorini Products Service")

app.include_router(products_router)

@app.get("/")
def root():
    return {"service": "products_service", "status": "running"}