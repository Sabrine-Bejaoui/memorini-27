from sqlalchemy import Column, Integer, String, Float, Text, Boolean
from database import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    category = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    price = Column(Float, nullable=False)
    main_image = Column(String, nullable=False)
    images = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    stock_mode = Column(String, nullable=False, default="none")
    stock = Column(Integer, nullable=True)
    variant_stock = Column(Text, nullable=True)