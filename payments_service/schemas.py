from pydantic import BaseModel

class PaymentCreate(BaseModel):
    order_id: int
    user_id: int
    amount: float
    method: str = "cash_on_delivery"

class PaymentResponse(PaymentCreate):
    id: int
    status: str

    class Config:
        from_attributes = True