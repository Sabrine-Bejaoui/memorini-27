from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from crud import (
    create_admin_user,
    delete_user,
    get_all_users,
    get_user_by_email,
    get_user_by_id,
    update_user,
    update_user_role,
    update_user_status,
)
from database import get_db
from schemas import AdminCreate, UserResponse, UserRoleUpdate, UserStatusUpdate, UserUpdate
from auth import require_admin

router = APIRouter(
    prefix="/users",
    tags=["Users Admin"],
    dependencies=[Depends(require_admin)],
)


@router.get("/")
def list_users(db: Session = Depends(get_db)):
    users = get_all_users(db)
    return {
        "success": True,
        "data": [UserResponse.model_validate(u).model_dump() for u in users]
    }


@router.post("/admins")
def add_admin(payload: AdminCreate, db: Session = Depends(get_db)):
    existing = get_user_by_email(db, payload.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email déjà utilisé")
    user = create_admin_user(db, payload)
    return {
        "success": True,
        "data": UserResponse.model_validate(user).model_dump(),
    }

@router.get("/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")
    return {"success": True, "data": UserResponse.model_validate(user).model_dump()}

@router.put("/{user_id}")
def edit_user(user_id: int, payload: UserUpdate, db: Session = Depends(get_db)):
    user = update_user(db, user_id, payload)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")
    return {"success": True, "data": UserResponse.model_validate(user).model_dump()}


@router.put("/{user_id}/role")
def set_user_role(user_id: int, payload: UserRoleUpdate, db: Session = Depends(get_db)):
    allowed = {"admin", "client"}
    if payload.role not in allowed:
        raise HTTPException(status_code=400, detail="Rôle invalide")
    user = update_user_role(db, user_id, payload.role)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")
    return {
        "success": True,
        "data": UserResponse.model_validate(user).model_dump()
    }


@router.put("/{user_id}/status")
def set_user_status(user_id: int, payload: UserStatusUpdate, db: Session = Depends(get_db)):
    user = update_user_status(db, user_id, payload.is_active)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")
    return {
        "success": True,
        "data": UserResponse.model_validate(user).model_dump()
    }


@router.delete("/{user_id}")
def remove_user(user_id: int, db: Session = Depends(get_db)):
    deleted = delete_user(db, user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")
    return {"success": True, "message": "Utilisateur supprimé"}
