from sqlalchemy.orm import Session
import json
from models import Order
from schemas import OrderCreate, OrderUpdate

def create_order(db: Session, order: OrderCreate):
    order_data = order.model_dump()
    if isinstance(order_data.get('items'), (list, dict)):
        order_data['items'] = json.dumps(order_data['items'])
    new_order = Order(**order_data)
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    return new_order

def get_user_orders(db: Session, user_id: int):
    return db.query(Order).filter(Order.user_id == user_id).all()

def get_all_orders(db: Session):
    return db.query(Order).all()

def get_order(db: Session, order_id: int):
    return db.query(Order).filter(Order.id == order_id).first()

def update_order(db: Session, order_id: int, payload: OrderUpdate):
    order = get_order(db, order_id)
    if not order:
        return None
    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(order, field, value)
    db.commit()
    db.refresh(order)
    return order

def update_order_status(db: Session, order_id: int, status: str):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        return None
    order.status = status
    db.commit()
    db.refresh(order)
    return order


def delete_order(db: Session, order_id: int):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        return False
    db.delete(order)
    db.commit()
    return True