from sqlalchemy import Column, Integer, String, Float
from database import Base

class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, nullable=False)
    user_id = Column(Integer, nullable=False)
    amount = Column(Float, nullable=False)
    method = Column(String, default="cash_on_delivery")
    status = Column(String, default="pending")