import os
from fastapi import HTTPException, Header
from jose import jwt, JWTError
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = os.getenv("JWT_ALGORITHM")

def verify_token(authorization: str = Header(None)):
    if not SECRET_KEY or not ALGORITHM:
        raise HTTPException(status_code=500, detail="Configuration JWT manquante")

    if not authorization:
        raise HTTPException(status_code=401, detail="Token manquant")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Format Authorization invalide")

    try:
        token = authorization.replace("Bearer ", "")
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(status_code=401, detail="Token invalide")