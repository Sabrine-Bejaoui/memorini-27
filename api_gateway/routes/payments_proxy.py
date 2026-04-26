from fastapi import APIRouter, Request, Depends
from core.config import PAYMENTS_SERVICE_URL
from core.proxy import proxy_request
from core.security import verify_token

router = APIRouter(tags=["Payments Gateway"])

@router.api_route("/payments/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def payments_proxy(path: str, request: Request, user=Depends(verify_token)):
    if user.get("role") == "admin":
        raise HTTPException(status_code=403, detail="Accès client requis")
    return await proxy_request(request, f"{PAYMENTS_SERVICE_URL}/payments/{path}")

@router.api_route("/payments", methods=["POST"])
async def payments_root_proxy(request: Request, user=Depends(verify_token)):
    if user.get("role") == "admin":
        raise HTTPException(status_code=403, detail="Accès client requis")
    return await proxy_request(request, f"{PAYMENTS_SERVICE_URL}/payments/")