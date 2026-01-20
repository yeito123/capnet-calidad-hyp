from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List


class CalidadResponse(BaseModel):
    id: int
    id_chip: Optional[int]
    id_hd: Optional[int]
    fecha: Optional[datetime]
    status: Optional[str]
    color: Optional[str]
    vehiculo: Optional[str]
    no_orden: Optional[str]
    no_placas: Optional[str]
    id_tecnico: Optional[int]
    id_asesor: Optional[int]
    fecha_hora_ini_oper: Optional[datetime]
    fecha_hora_fin_oper: Optional[datetime]
    status_os: Optional[str]
    kilometraje: Optional[int]
    contacto_nombre: Optional[str]
    contacto_telefono: Optional[str]
    tmp_real: Optional[int]
    tmp_original: Optional[int]
    servicio: Optional[str]
    servicio_capturado: Optional[str]
    id_fase: Optional[int]
    tecnico: Optional[str]
    asesor: Optional[str]


class ComentarioResponse(BaseModel):
    id_chip: int
    fecha: datetime
    status: str
    cve_usuario: str
    id_linea: int
    comentario: str


class CrearComentarioRequest(BaseModel):
    id_chip: int
    status: str
    cve_usuario: str
    comentario: str


class UsuarioRequest(BaseModel):
    usuario: str
    status_os: Optional[str]
