from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes.users_proxy import router as users_router
from routes.products_proxy import router as products_router
from routes.orders_proxy import router as orders_router
from routes.payments_proxy import router as payments_router

app = FastAPI(title="Memorini API Gateway")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users_router)
app.include_router(products_router)
app.include_router(orders_router)
app.include_router(payments_router)

@app.get("/")
def root():
    return {"service": "api_gateway", "status": "running"}