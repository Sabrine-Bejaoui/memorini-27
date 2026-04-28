from sqlalchemy.orm import Session
import json
from typing import Optional
from models import Product
from schemas import ProductCreate, ProductUpdate


def _normalize_stock_fields(payload: dict):
    stock_mode = payload.get("stock_mode", "none")
    if stock_mode == "none":
        payload["stock"] = None
        payload["variant_stock"] = None
    elif stock_mode == "global":
        payload["variant_stock"] = None
    elif stock_mode == "variant":
        payload["stock"] = None
    variants = payload.get("variant_stock")
    if variants is not None and not isinstance(variants, str):
        payload["variant_stock"] = json.dumps(variants)
    return payload

def get_products(db: Session):
    return db.query(Product).all()

def get_product(db: Session, product_id: int):
    return db.query(Product).filter(Product.id == product_id).first()

def create_product(db: Session, product: ProductCreate):
    payload = _normalize_stock_fields(product.model_dump())
    new_product = Product(**payload)
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return new_product


def update_product(db: Session, product_id: int, payload: ProductUpdate):
    product = get_product(db, product_id)
    if not product:
        return None

    updates = payload.model_dump(exclude_unset=True)
    if updates:
        updates = _normalize_stock_fields(updates)
    for field, value in updates.items():
        setattr(product, field, value)

    db.commit()
    db.refresh(product)
    return product


def delete_product(db: Session, product_id: int):
    product = get_product(db, product_id)
    if not product:
        return None

    db.delete(product)
    db.commit()
    return product


def consume_product_stock(
    db: Session,
    product_id: int,
    qty: int,
    size: Optional[str] = None,
    color: Optional[str] = None,
):
    product = (
        db.query(Product).filter(Product.id == product_id).with_for_update().first()
    )
    if not product:
        return None, "Produit introuvable"
    if qty < 1:
        return None, "Quantité invalide"

    mode = product.stock_mode or "none"
    if mode == "none":
        return product, None

    if mode == "global":
        current = product.stock or 0
        if current < qty:
            return None, f"Stock insuffisant pour {product.name}"
        product.stock = current - qty
        db.commit()
        db.refresh(product)
        return product, None

    raw = product.variant_stock
    variants = []
    if raw:
        try:
            variants = json.loads(raw)
        except Exception:
            variants = []

    if not size or not color:
        return None, (
            f"Le produit {product.name} exige une variante (taille/couleur)."
        )

    target = None
    for variant in variants:
        if (
            str(variant.get("size", "")).lower() == size.lower()
            and str(variant.get("color", "")).lower() == color.lower()
        ):
            target = variant
            break

    if target is None:
        return None, f"Variante {size}/{color} indisponible pour {product.name}"

    current = int(target.get("stock", 0))
    if current < qty:
        return None, f"Stock insuffisant pour la variante {size}/{color}"

    target["stock"] = current - qty
    product.variant_stock = json.dumps(variants)
    db.commit()
    db.refresh(product)
    return product, None