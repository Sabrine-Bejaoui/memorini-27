from sqlalchemy.orm import Session

from models import User
from schemas import AdminCreate, UserRegister, UserUpdate
from auth import hash_password, verify_password


def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()


def create_user(db: Session, user: UserRegister):
    hashed_password = hash_password(user.password)
    user_count = db.query(User).count()
    initial_role = "admin" if user_count == 0 else "client"

    new_user = User(
        full_name=user.full_name,
        email=user.email,
        phone=user.phone,
        hashed_password=hashed_password,
        role=initial_role
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user


def authenticate_user(db: Session, email: str, password: str):
    user = get_user_by_email(db, email)

    if not user:
        return None

    if not verify_password(password, user.hashed_password):
        return None

    return user


def ensure_admin_role_if_configured(db: Session, user: User):
    return user


def create_admin_user(db: Session, payload: AdminCreate):
    hashed_password = hash_password(payload.password)
    user = User(
        full_name=payload.full_name,
        email=payload.email,
        phone=payload.phone,
        hashed_password=hashed_password,
        role="admin",
        is_active=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def get_all_users(db: Session):
    return db.query(User).order_by(User.id.desc()).all()


def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()


def update_user_role(db: Session, user_id: int, role: str):
    user = get_user_by_id(db, user_id)

    if not user:
        return None

    user.role = role
    db.commit()
    db.refresh(user)

    return user

def update_user(db: Session, user_id: int, payload: UserUpdate):
    user = get_user_by_id(db, user_id)
    if not user:
        return None
    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return user


def update_user_status(db: Session, user_id: int, is_active: bool):
    user = get_user_by_id(db, user_id)

    if not user:
        return None

    user.is_active = is_active
    db.commit()
    db.refresh(user)

    return user


def delete_user(db: Session, user_id: int):
    user = get_user_by_id(db, user_id)
    if not user:
        return False
    db.delete(user)
    db.commit()
    return True