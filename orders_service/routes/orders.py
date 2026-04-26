from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from schemas import OrderCreate, OrderResponse, OrderUpdate
from crud import create_order, delete_order, get_all_orders, get_user_orders, update_order_status, get_order, update_order
from typing import List

router = APIRouter(prefix="/orders", tags=["Orders"])

@router.post("/")
def add_order(order: OrderCreate, db: Session = Depends(get_db)):
    new_order = create_order(db, order)
    return {
        "success": True,
        "data": OrderResponse.model_validate(new_order).model_dump()
    }

@router.get("/my-orders/{user_id}")
def my_orders(user_id: int, db: Session = Depends(get_db)):
    orders = get_user_orders(db, user_id)
    return {
        "success": True,
        "data": [OrderResponse.model_validate(o).model_dump() for o in orders]
    }

@router.get("/")
def all_orders(db: Session = Depends(get_db)):
    orders = get_all_orders(db)
    return {
        "success": True,
        "data": [OrderResponse.model_validate(o).model_dump() for o in orders]
    }

@router.get("/{order_id}")
def order_detail(order_id: int, db: Session = Depends(get_db)):
    order = get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Commande introuvable")
    return {
        "success": True,
        "data": OrderResponse.model_validate(order).model_dump()
    }

@router.put("/{order_id}")
def edit_order(order_id: int, payload: OrderUpdate, db: Session = Depends(get_db)):
    if payload.status:
        allowed = ["Pending", "Confirmed", "Shipped", "Delivered", "Cancelled"]
        if payload.status not in allowed:
            raise HTTPException(status_code=400, detail="Statut invalide")
    order = update_order(db, order_id, payload)
    if not order:
        raise HTTPException(status_code=404, detail="Commande introuvable")
    return {
        "success": True,
        "data": OrderResponse.model_validate(order).model_dump()
    }

@router.put("/{order_id}/status")
def change_status(order_id: int, status: str, db: Session = Depends(get_db)):
    allowed = ["Pending", "Confirmed", "Shipped", "Delivered", "Cancelled"]
    if status not in allowed:
        raise HTTPException(status_code=400, detail="Statut invalide")

    order = update_order_status(db, order_id, status)
    if not order:
        raise HTTPException(status_code=404, detail="Commande introuvable")

    return {
        "success": True,
        "data": OrderResponse.model_validate(order).model_dump()
    }


@router.delete("/{order_id}")
def remove_order(order_id: int, db: Session = Depends(get_db)):
    deleted = delete_order(db, order_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Commande introuvable")
    return {"success": True, "message": "Commande supprimée"}