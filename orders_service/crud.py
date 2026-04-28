from sqlalchemy.orm import Session
import json
import os
from urllib import request, error
from models import Order
from schemas import OrderCreate, OrderUpdate


PRODUCTS_SERVICE_URL = os.getenv("PRODUCTS_SERVICE_URL", "http://products_service:8002")


def _extract_product_id(raw_id):
    if isinstance(raw_id, int):
        return raw_id
    if raw_id is None:
        return None
    text = str(raw_id)
    if text.isdigit():
        return int(text)
    if text.startswith("product-"):
        maybe = text.replace("product-", "", 1)
        if maybe.isdigit():
            return int(maybe)
    return None


def _parse_order_items(raw_items):
    if isinstance(raw_items, list):
        return raw_items
    if isinstance(raw_items, dict):
        return [raw_items]
    if isinstance(raw_items, str):
        try:
            decoded = json.loads(raw_items)
            if isinstance(decoded, list):
                return decoded
            if isinstance(decoded, dict):
                return [decoded]
        except Exception:
            return []
    return []


def _consume_stock_for_product_item(item):
    product_id = _extract_product_id(item.get("product_id") or item.get("id"))
    if not product_id:
        return
    qty = int(item.get("qty", 1) or 1)
    payload = {
        "qty": qty,
        "size": item.get("size"),
        "color": item.get("color"),
    }
    req = request.Request(
        url=f"{PRODUCTS_SERVICE_URL}/products/{product_id}/consume-stock",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with request.urlopen(req, timeout=8) as response:
            raw = response.read().decode("utf-8")
            if not raw:
                return
            parsed = json.loads(raw)
            if isinstance(parsed, dict) and parsed.get("success") is False:
                raise ValueError(parsed.get("detail") or "Stock indisponible")
    except error.HTTPError as exc:
        detail = "Stock indisponible"
        try:
            body = exc.read().decode("utf-8")
            payload = json.loads(body) if body else {}
            if isinstance(payload, dict):
                detail = payload.get("detail") or detail
        except Exception:
            pass
        raise ValueError(detail) from exc
    except error.URLError as exc:
        raise ValueError("Service stock indisponible, réessayez.") from exc

def create_order(db: Session, order: OrderCreate):
    order_data = order.model_dump()
    parsed_items = _parse_order_items(order_data.get("items"))
    for item in parsed_items:
        if isinstance(item, dict):
            _consume_stock_for_product_item(item)
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