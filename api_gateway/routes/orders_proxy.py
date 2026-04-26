from fastapi import APIRouter, Request, Depends, HTTPException
from core.config import ORDERS_SERVICE_URL
from core.proxy import proxy_request
from core.security import verify_token

router = APIRouter(tags=["Orders Gateway"])

@router.api_route("/orders/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def orders_proxy(path: str, request: Request, user=Depends(verify_token)):
    is_admin_only = request.method in {"PUT", "DELETE"} or path.endswith("/status")
    is_client_only = path.startswith("my-orders")

    if is_admin_only and user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Accès admin requis")
    
    if is_client_only and user.get("role") == "admin":
        raise HTTPException(status_code=403, detail="Accès client requis")

    return await proxy_request(request, f"{ORDERS_SERVICE_URL}/orders/{path}")

@router.api_route("/orders", methods=["GET", "POST"])
async def orders_root_proxy(request: Request, user=Depends(verify_token)):
    if request.method == "GET" and user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Accès admin requis")
    
    if request.method == "POST" and user.get("role") == "admin":
        raise HTTPException(status_code=403, detail="Accès client requis")

    return await proxy_request(request, f"{ORDERS_SERVICE_URL}/orders/")