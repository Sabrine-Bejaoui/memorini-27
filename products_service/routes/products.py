from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import json
from database import get_db
from schemas import (
    ProductCreate,
    ProductResponse,
    ProductStockConsumeRequest,
    ProductStockConsumeResponse,
    ProductUpdate,
)
from crud import (
    consume_product_stock,
    create_product,
    delete_product,
    get_product,
    get_products,
    update_product,
)
from typing import List

router = APIRouter(prefix="/products", tags=["Products"])


def _serialize_product(product):
    data = ProductResponse.model_validate(product).model_dump()
    raw_variants = data.get("variant_stock")
    if isinstance(raw_variants, str) and raw_variants.strip():
        try:
            data["variant_stock"] = json.loads(raw_variants)
        except Exception:
            data["variant_stock"] = []
    return data

@router.get("/")
def list_products(db: Session = Depends(get_db)):
    products = get_products(db)
    return {
        "success": True,
        "data": [_serialize_product(p) for p in products]
    }

@router.get("/{product_id}")
def product_detail(product_id: int, db: Session = Depends(get_db)):
    product = get_product(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return {
        "success": True,
        "data": _serialize_product(product)
    }

@router.post("/")
def add_product(product: ProductCreate, db: Session = Depends(get_db)):
    new_product = create_product(db, product)
    return {
        "success": True,
        "data": _serialize_product(new_product)
    }


@router.put("/{product_id}")
def edit_product(product_id: int, payload: ProductUpdate, db: Session = Depends(get_db)):
    product = update_product(db, product_id, payload)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return {
        "success": True,
        "data": _serialize_product(product)
    }


@router.delete("/{product_id}")
def remove_product(product_id: int, db: Session = Depends(get_db)):
    product = delete_product(db, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return {"success": True, "message": "Produit supprimé"}


@router.post("/{product_id}/consume-stock")
def consume_stock(
    product_id: int,
    payload: ProductStockConsumeRequest,
    db: Session = Depends(get_db),
):
    product, error = consume_product_stock(
        db=db,
        product_id=product_id,
        qty=payload.qty,
        size=payload.size,
        color=payload.color,
    )
    if error:
        raise HTTPException(status_code=400, detail=error)
    serialized = _serialize_product(product)
    return {
        "success": True,
        "data": ProductStockConsumeResponse(
            id=serialized["id"],
            stock_mode=serialized.get("stock_mode", "none"),
            stock=serialized.get("stock"),
            variant_stock=serialized.get("variant_stock") or [],
        ).model_dump(),
    }