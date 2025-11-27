# main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Error system
from app.errors.errors import AppError
from app.errors.error_handlers import app_error_handler

# Settings
from app.core.config import settings

# Routers (regístralos aquí)
from app.modules.calidad.calidad_router import router as calidad_router


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        description="API Backend Tablero HYP Calidad",
    )

    # ============================================================
    # Error Handlers
    # ============================================================
    app.add_exception_handler(AppError, app_error_handler)

    # ============================================================
    # CORS
    # ============================================================
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ============================================================
    # Routers
    # ============================================================
    router_prefix = "/api"
    app.include_router(calidad_router, prefix=router_prefix)

    # ============================================================
    # Root endpoint (healthcheck)
    # ============================================================
    @app.get("/")
    def root():
        return {
            "status": "ok",
            "project": settings.PROJECT_NAME,
            "version": settings.VERSION,
        }

    return app


app = create_app()
