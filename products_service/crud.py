from sqlalchemy.orm import Session
from models import Product
from schemas import ProductCreate, ProductUpdate

def get_products(db: Session):
    return db.query(Product).all()

def get_product(db: Session, product_id: int):
    return db.query(Product).filter(Product.id == product_id).first()

def create_product(db: Session, product: ProductCreate):
    new_product = Product(**product.model_dump())
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return new_product


def update_product(db: Session, product_id: int, payload: ProductUpdate):
    product = get_product(db, product_id)
    if not product:
        return None

    updates = payload.model_dump(exclude_unset=True)
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