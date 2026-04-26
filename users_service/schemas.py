from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class UserRegister(BaseModel):
    full_name: str = Field(min_length=2, max_length=120)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)
    phone: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)

class UserResponse(BaseModel):
    id: int
    full_name: str
    email: str
    phone: Optional[str]
    role: str
    is_active: bool

    class Config:
        from_attributes = True


class UserRoleUpdate(BaseModel):
    role: str


class UserStatusUpdate(BaseModel):
    is_active: bool

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None