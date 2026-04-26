from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import Payment
from schemas import PaymentCreate, PaymentResponse

router = APIRouter(prefix="/payments", tags=["Payments"])

@router.post("/")
def create_payment(payment: PaymentCreate, db: Session = Depends(get_db)):
    # payment.dict() might be deprecated in Pydantic v2, but keeping it as is or model_dump()
    new_payment = Payment(**payment.model_dump())
    db.add(new_payment)
    db.commit()
    db.refresh(new_payment)
    return {
        "success": True,
        "data": PaymentResponse.model_validate(new_payment).model_dump()
    }