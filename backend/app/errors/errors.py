# app/core/errors.py

from typing import Optional


class AppError(Exception):
    """Error base para toda la plataforma."""
    def __init__(self, code: str, message: str, detail: Optional[str] = None):
        self.code = code          # código interno (ej: 'not_found')
        self.message = message    # mensaje amigable
        self.detail = detail      # debug info
        super().__init__(message)


class NotFoundError(AppError):
    """Error: recurso no encontrado."""
    def __init__(self, detail: Optional[str] = None):
        super().__init__("not_found", "El recurso solicitado no existe.", detail)


class ValidationError(AppError):
    """Error: datos inválidos o incompletos."""
    def __init__(self, detail: Optional[str] = None):
        super().__init__("validation_error", "Datos inválidos.", detail)


class DatabaseError(AppError):
    """Error: algo falló en DB."""
    def __init__(self, detail: Optional[str] = None):
        super().__init__("database_error", "Error en la base de datos.", detail)


class UnauthorizedError(AppError):
    """Error: autenticación fallida."""
    def __init__(self, detail: Optional[str] = None):
        super().__init__("unauthorized", "No autorizado.", detail)
