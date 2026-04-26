import httpx
from fastapi import Request, Response
from fastapi.responses import JSONResponse


async def proxy_request(request: Request, target_url: str):
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            body = await request.body()
            response = await client.request(
                method=request.method,
                url=target_url,
                headers={key: value for key, value in request.headers.items() if key.lower() not in ["host", "content-length"]},
                content=body,
                params=request.query_params,
            )

            content_type = response.headers.get("content-type", "")

            if "application/json" in content_type:
                try:
                    return JSONResponse(status_code=response.status_code, content=response.json())
                except ValueError:
                    return Response(status_code=response.status_code, content=response.text, media_type="text/plain")

            return Response(
                status_code=response.status_code,
                content=response.content,
                media_type=content_type or "text/plain",
            )
    except httpx.RequestError as e:
        return JSONResponse(status_code=502, content={"detail": f"Service injoignable: {str(e)}"})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return JSONResponse(status_code=500, content={"detail": f"Erreur proxy interne: {str(e)}"})