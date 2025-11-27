# app/core/error_catalog.py

ERROR_CATALOG = {
    "not_found": {
        "http_code": 404,
        "message": "El recurso solicitado no existe."
    },
    "validation_error": {
        "http_code": 422,
        "message": "Los datos proporcionados no son válidos."
    },
    "database_error": {
        "http_code": 500,
        "message": "Se produjo un error en la base de datos."
    },
    "unauthorized": {
        "http_code": 401,
        "message": "No autorizado."
    },
}
