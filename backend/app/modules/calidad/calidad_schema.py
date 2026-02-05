# app/modules/calidad/calidad_schema.py

from typing import Dict, Any
from .calidad_model import CalidadModel, CalidadComentarioModel


class CalidadSchema:

    @staticmethod
    def db_to_model(row: Dict[str, Any]) -> CalidadModel:
        """
        Convierte una fila de SQL (dict) al modelo CalidadModel.
        """

        def calculate_tracker_url(no_orden: str) -> str:
            # Aquí podrías usar settings.TRACKER_URL y formatearlo con no_orden
            from app.core.config import settings

            return settings.TRACKER_URL.format(no_order=no_orden)

        return CalidadModel(
            id=row.get("id"),
            id_chip=row.get("idChip"),
            id_hd=row.get("id_hd"),
            fecha=row.get("fecha"),
            status=row.get("status"),
            color=row.get("color"),
            vehiculo=row.get("vehiculo"),
            no_orden=row.get("noOrden"),
            no_placas=row.get("noPlacas"),
            id_tecnico=row.get("idTecnico"),
            id_asesor=row.get("idAsesor"),
            fecha_hora_ini_oper=row.get("fecha_hora_ini_oper"),
            fecha_hora_fin_oper=row.get("fecha_hora_fin_oper"),
            status_os=row.get("status_os"),
            kilometraje=row.get("kilometraje"),
            contacto_nombre=row.get("contactoNombre"),
            contacto_telefono=row.get("contactoTelefono"),
            tmp_real=row.get("tmp_Real"),
            tmp_original=row.get("tmp_original"),
            servicio=row.get("servicio"),
            servicio_capturado=row.get("servicioCapturado"),
            id_fase=row.get("idTecnicoAsi"),
            tecnico=row.get("tecnico"),
            asesor=row.get("asesor"),
            tracker_url=(
                calculate_tracker_url(row.get("noOrden"))
                if row.get("noOrden")
                else None
            ),
        )

    @staticmethod
    def model_to_db(model: CalidadModel) -> Dict[str, Any]:
        """
        Convierte un modelo CalidadModel a dict listo para SQL.
        Útil cuando hagamos update/insert más adelante.
        """
        return {
            "id": model.id,
            "idChip": model.id_chip,
            "id_hd": model.id_hd,
            "fecha": model.fecha,
            "status": model.status,
            "color": model.color,
            "vehiculo": model.vehiculo,
            "noOrden": model.no_orden,
            "noPlacas": model.no_placas,
            "idTecnico": model.id_tecnico,
            "idAsesor": model.id_asesor,
            "fecha_hora_ini_oper": model.fecha_hora_ini_oper,
            "fecha_hora_fin_oper": model.fecha_hora_fin_oper,
            "status_os": model.status_os,
            "kilometraje": model.kilometraje,
            "contactoNombre": model.contacto_nombre,
            "contactoTelefono": model.contacto_telefono,
            "tmp_Real": model.tmp_real,
            "tmp_original": model.tmp_original,
            "servicio": model.servicio,
            "servicioCapturado": model.servicio_capturado,
            "idTecnicoAsi": model.id_fase,
            "tecnico": model.tecnico,
            "asesor": model.asesor,
        }


class ComentarioSchema:

    @staticmethod
    def db_to_model(row: Dict[str, Any]) -> CalidadComentarioModel:
        return CalidadComentarioModel(
            id_chip=row.get("idChip"),
            fecha=row.get("fecha"),
            status=row.get("Status"),
            cve_usuario=row.get("cveUsuario"),
            id_linea=row.get("idLinea"),
            comentario=row.get("Comentario"),
        )
