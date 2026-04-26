from fastapi import APIRouter, Request, Depends, HTTPException
from core.config import PRODUCTS_SERVICE_URL
from core.proxy import proxy_request
from core.security import verify_token

router = APIRouter(tags=["Products Gateway"])

@router.api_route("/products/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def products_proxy(path: str, request: Request):
    if request.method != "GET":
        from core.security import verify_token
        user = verify_token(request.headers.get("Authorization"))
        if user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="Accès admin requis")
    return await proxy_request(request, f"{PRODUCTS_SERVICE_URL}/products/{path}")

@router.api_route("/products", methods=["GET", "POST"])
async def products_root_proxy(request: Request):
    if request.method != "GET":
        from core.security import verify_token
        user = verify_token(request.headers.get("Authorization"))
        if user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="Accès admin requis")
    return await proxy_request(request, f"{PRODUCTS_SERVICE_URL}/products/")