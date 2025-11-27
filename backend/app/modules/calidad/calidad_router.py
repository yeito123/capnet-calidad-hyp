# app/modules/calidad/calidad_router.py

from fastapi import APIRouter
from typing import List

from .calidad_service import CalidadService
from .calidad_schema_api import (
    CalidadResponse,
    ComentarioResponse,
    CrearComentarioRequest,
    UsuarioRequest,
)

router = APIRouter(prefix="/calidad", tags=["Calidad"])

service = CalidadService()


# ============================================================
# 0. Authentication
# ============================================================
@router.get("/auth/me/")
def auth_me():
    return {"status": "ok", "message": "Authenticated"}


# ============================================================
# 1. Vehículos actualmente en fase de calidad
# ============================================================
@router.get("/", response_model=List[CalidadResponse])
def listar_en_fase():
    return service.get_vehiculos_en_fase_calidad()


# ============================================================
# 2. Obtener vehículo por idHD (dentro de la fase)
# ============================================================
@router.get("/vehiculo/{id_hd}/", response_model=List[CalidadResponse])
def obtener_por_id_hd(id_hd: int):
    return service.get_vehiculo_por_id(id_hd)


# ============================================================
# 3. Obtener una calidad por ID (PK)
# ============================================================
@router.get("/item/{id}/", response_model=CalidadResponse)
def obtener_por_id(id: int):
    return service.get_calidad_por_id(id)


# ============================================================
# 4. Obtener info del vehículo en fase previa
# ============================================================
@router.get("/vehiculo-info/{id_hd}/", response_model=CalidadResponse)
def obtener_info_previa(id_hd: int):
    return service.get_vehiculo_info(id_hd)


# ============================================================
# 5. Historial de comentarios
# ============================================================
@router.get("/comentarios/{id_chip}/", response_model=List[ComentarioResponse])
def obtener_comentarios(id_chip: int):
    return service.get_comentarios(id_chip)


# ============================================================
# 6. Agregar comentario
# ============================================================
@router.post("/comentarios/", response_model=ComentarioResponse)
def agregar_comentario(data: CrearComentarioRequest):
    return service.agregar_comentario(data)


# ============================================================
# 7. Iniciar una calidad
# ============================================================
@router.post("/{id}/iniciar/", response_model=CalidadResponse)
def iniciar_calidad(id: int, body: UsuarioRequest):
    return service.iniciar_calidad(id, body.usuario)


# ============================================================
# 8. Finalizar una calidad
# ============================================================
@router.post("/{id}/finalizar/", response_model=CalidadResponse)
def finalizar_calidad(id: int, body: UsuarioRequest):
    return service.finalizar_calidad(id, body.usuario)
