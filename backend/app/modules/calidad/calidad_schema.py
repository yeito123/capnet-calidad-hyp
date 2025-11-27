# app/modules/calidad/calidad_schema.py

from typing import Dict, Any
from .calidad_model import CalidadModel, CalidadComentarioModel


class CalidadSchema:

    @staticmethod
    def db_to_model(row: Dict[str, Any]) -> CalidadModel:
        """
        Convierte una fila de SQL (dict) al modelo CalidadModel.
        """

        return CalidadModel(
            id=row.get("id"),
            id_chip=row.get("idChip"),
            id_hd=row.get("id_hd"),
            fecha=row.get("fecha"),
            status=row.get("Status"),
            vehiculo=row.get("Vehiculo"),
            no_orden=row.get("noOrden"),
            no_placas=row.get("noPlacas"),
            id_tecnico=row.get("idTecnico"),
            id_asesor=row.get("idAsesor"),
            fecha_hora_ini_oper=row.get("fecha_Hora_ini_Oper"),
            fecha_hora_fin_oper=row.get("Fecha_Hora_Fin_Oper"),
            status_os=row.get("Status_OS"),
            kilometraje=row.get("Kilometraje"),
            contacto_nombre=row.get("ContactoNombre"),
            contacto_telefono=row.get("ContactoTelefono"),
            tmp_real=row.get("Tmp_Real"),
            tmp_original=row.get("Tmp_original"),
            servicio=row.get("Servicio"),
            servicio_capturado=row.get("servicioCapturado"),
            id_fase=row.get("idTecnicoAsi"),
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
            "Status": model.status,
            "Vehiculo": model.vehiculo,
            "noOrden": model.no_orden,
            "noPlacas": model.no_placas,
            "idTecnico": model.id_tecnico,
            "idAsesor": model.id_asesor,
            "fecha_Hora_ini_Oper": model.fecha_hora_ini_oper,
            "Fecha_Hora_Fin_Oper": model.fecha_hora_fin_oper,
            "Status_OS": model.status_os,
            "Kilometraje": model.kilometraje,
            "ContactoNombre": model.contacto_nombre,
            "ContactoTelefono": model.contacto_telefono,
            "Tmp_Real": model.tmp_real,
            "Tmp_original": model.tmp_original,
            "Servicio": model.servicio,
            "servicioCapturado": model.servicio_capturado,
            "idTecnicoAsi": model.id_fase,
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
