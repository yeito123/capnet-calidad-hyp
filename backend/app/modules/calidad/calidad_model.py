from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class CalidadModel(BaseModel):
    id: int
    id_chip: Optional[int]
    id_hd: Optional[int]
    fecha: Optional[datetime]
    status: Optional[str]
    vehiculo: Optional[str]
    no_orden: Optional[str]
    no_placas: Optional[str]
    id_tecnico: Optional[int]
    id_asesor: Optional[int]
    fecha_hora_ini_oper: Optional[datetime]
    fecha_hora_fin_oper: Optional[datetime]
    status: Optional[str]  # Iniciada, Detenida, Terminado, Pendiente
    status_os: Optional[str]  # ABIERTA, EN PROCESO, Finalizada
    kilometraje: Optional[int]
    contacto_nombre: Optional[str]
    contacto_telefono: Optional[str]
    tmp_real: Optional[int]
    tmp_original: Optional[int]
    servicio: Optional[str]
    servicio_capturado: Optional[str]
    id_fase: Optional[int]


class CalidadComentarioModel(BaseModel):
    id_chip: int
    fecha: datetime
    status: str
    cve_usuario: str
    id_linea: int
    comentario: str


class CrearComentario(BaseModel):
    id_chip: int
    status: str
    cve_usuario: str
    comentario: str
