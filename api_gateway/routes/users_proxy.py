from fastapi import APIRouter, Request, Depends, HTTPException
from core.config import USERS_SERVICE_URL
from core.proxy import proxy_request
from core.security import verify_token

router = APIRouter(tags=["Users Gateway"])

@router.api_route("/auth/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def users_proxy(path: str, request: Request):
    return await proxy_request(request, f"{USERS_SERVICE_URL}/auth/{path}")


@router.api_route("/users/{path:path}", methods=["GET", "PUT", "POST", "DELETE"])
async def users_admin_proxy(path: str, request: Request, user=Depends(verify_token)):
    if user.get("role") != "admin":
        if request.method in ["GET", "PUT"] and path.isdigit() and int(path) == user.get("user_id"):
            pass
        else:
            raise HTTPException(status_code=403, detail="Accès admin requis")
    return await proxy_request(request, f"{USERS_SERVICE_URL}/users/{path}")


@router.api_route("/users", methods=["GET"])
async def users_admin_root_proxy(request: Request, user=Depends(verify_token)):
    if user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Accès admin requis")
    return await proxy_request(request, f"{USERS_SERVICE_URL}/users/")