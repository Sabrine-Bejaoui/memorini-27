from pydantic import BaseModel
from typing import Optional, List, Literal


class ProductVariantStock(BaseModel):
    size: str
    color: str
    stock: int

class ProductCreate(BaseModel):
    name: str
    category: str
    description: str
    price: float
    main_image: str
    images: Optional[str] = None
    stock_mode: Literal["none", "global", "variant"] = "none"
    stock: Optional[int] = None
    variant_stock: Optional[List[ProductVariantStock]] = None

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
    stock_mode: Optional[Literal["none", "global", "variant"]] = None
    stock: Optional[int] = None
    variant_stock: Optional[List[ProductVariantStock]] = None


class ProductStockConsumeRequest(BaseModel):
    qty: int = 1
    size: Optional[str] = None
    color: Optional[str] = None


class ProductStockConsumeResponse(BaseModel):
    id: int
    stock_mode: str
    stock: Optional[int] = None
    variant_stock: List[ProductVariantStock] = []