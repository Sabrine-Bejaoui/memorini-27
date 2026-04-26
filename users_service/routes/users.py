from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from schemas import UserRegister, UserLogin, UserResponse
from crud import (
    authenticate_user,
    create_user,
    ensure_admin_role_if_configured,
    get_user_by_email,
)
from auth import create_access_token

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/register")
def register(user: UserRegister, db: Session = Depends(get_db)):
    existing_user = get_user_by_email(db, user.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email déjà utilisé")

    new_user = create_user(db, user)
    token = create_access_token({
        "sub": new_user.email,
        "user_id": new_user.id,
        "role": new_user.role
    })

    return {
        "access_token": token,
        "token_type": "bearer",
        "message": "Compte créé avec succès",
        "user": UserResponse.model_validate(new_user).model_dump()
    }

@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    authenticated_user = authenticate_user(db, user.email, user.password)
    if not authenticated_user:
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")
    authenticated_user = ensure_admin_role_if_configured(db, authenticated_user)

    token = create_access_token({
        "sub": authenticated_user.email,
        "user_id": authenticated_user.id,
        "role": authenticated_user.role
    })

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": UserResponse.model_validate(authenticated_user).model_dump()
    }

@router.post("/logout")
def logout():
    return {"success": True, "message": "Déconnexion réussie"}