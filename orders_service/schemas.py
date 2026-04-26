from pydantic import BaseModel
from typing import Optional, Union, Any

class OrderCreate(BaseModel):
    user_id: int
    full_name: str
    address: str
    city: str
    phone1: str
    phone2: Optional[str] = None
    total_price: float
    items: Union[str, list, dict, Any]

class OrderResponse(OrderCreate):
    id: int
    status: str

    class Config:
        from_attributes = True

class OrderUpdate(BaseModel):
    full_name: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    phone1: Optional[str] = None
    phone2: Optional[str] = None
    total_price: Optional[float] = None
    items: Optional[Union[str, list, dict, Any]] = None
    status: Optional[str] = None