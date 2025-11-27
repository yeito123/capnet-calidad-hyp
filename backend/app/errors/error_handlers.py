# app/core/error_handlers.py

from fastapi import Request
from fastapi.responses import JSONResponse
from .errors import AppError
from .error_catalog import ERROR_CATALOG


def app_error_handler(request: Request, exc: AppError):
    error_info = ERROR_CATALOG.get(exc.code, None)

    if not error_info:
        # fallback
        return JSONResponse(
            status_code=500,
            content={
                "code": "unknown_error",
                "message": "Error inesperado.",
                "detail": exc.detail,
            }
        )

    return JSONResponse(
        status_code=error_info["http_code"],
        content={
            "code": exc.code,
            "message": error_info["message"],
            "detail": exc.detail,
        }
    )
