from sqlalchemy import Column, Float, Integer, String, Text
from database import Base

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    full_name = Column(String, nullable=False)
    address = Column(Text, nullable=False)
    city = Column(String, nullable=False)
    phone1 = Column(String, nullable=False)
    phone2 = Column(String, nullable=True)
    total_price = Column(Float, nullable=False)
    items = Column(Text, nullable=False)
    status = Column(String, default="Pending")