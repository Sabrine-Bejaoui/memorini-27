from pydantic import BaseModel
from typing import Optional

class ProductCreate(BaseModel):
    name: str
    category: str
    description: str
    price: float
    main_image: str
    images: Optional[str] = None

class ProductResponse(ProductCreate):
    id: int
    is_active: bool

    class Config:
        from_attributes = True


class ProductUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    main_image: Optional[str] = None
    images: Optional[str] = None
    is_active: Optional[bool] = None