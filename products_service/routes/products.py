from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from schemas import ProductCreate, ProductResponse, ProductUpdate
from crud import create_product, delete_product, get_product, get_products, update_product
from typing import List

router = APIRouter(prefix="/products", tags=["Products"])

@router.get("/")
def list_products(db: Session = Depends(get_db)):
    products = get_products(db)
    return {
        "success": True,
        "data": [ProductResponse.model_validate(p).model_dump() for p in products]
    }

@router.get("/{product_id}")
def product_detail(product_id: int, db: Session = Depends(get_db)):
    product = get_product(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return {
        "success": True,
        "data": ProductResponse.model_validate(product).model_dump()
    }

@router.post("/")
def add_product(product: ProductCreate, db: Session = Depends(get_db)):
    new_product = create_product(db, product)
    return {
        "success": True,
        "data": ProductResponse.model_validate(new_product).model_dump()
    }


@router.put("/{product_id}")
def edit_product(product_id: int, payload: ProductUpdate, db: Session = Depends(get_db)):
    product = update_product(db, product_id, payload)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return {
        "success": True,
        "data": ProductResponse.model_validate(product).model_dump()
    }


@router.delete("/{product_id}")
def remove_product(product_id: int, db: Session = Depends(get_db)):
    product = delete_product(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return {"success": True, "message": "Produit supprimé"}