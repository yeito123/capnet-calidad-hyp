from typing import List, Optional
from app.core.db import DB
from app.errors.errors import NotFoundError, DatabaseError, ValidationError
from app.core.config import settings

from .calidad_model import (
    CalidadModel,
    CalidadComentarioModel,
    CrearComentario,
)

from .calidad_schema import CalidadSchema, ComentarioSchema


class CalidadService:

    def __init__(self):
        self.db = DB()
        self.calidad_fase_id = settings.CALIDAD_FASE_ID
        self.previus_fase_id = settings.PREVIUS_FASE_ID

    # ============================================================
    # 1. Vehículos actualmente en fase de calidad
    # ============================================================
    def get_vehiculos_en_fase_calidad(self) -> List[CalidadModel]:
        query = """
        SELECT *
        FROM TYT_LV_TBL_CONTROL_CITAS
        WHERE idTecnicoAsi = ?
        """
        try:
            rows = self.db.select(query, (self.calidad_fase_id,))
        except Exception as e:
            raise DatabaseError(detail=str(e))

        return [CalidadSchema.db_to_model(row) for row in rows]

    # ============================================================
    # 2. Vehículo por id_hd dentro de la fase de calidad
    # ============================================================
    def get_vehiculo_por_id(self, id_hd: int) -> List[CalidadModel]:
        query = """
        SELECT *
        FROM TYT_LV_TBL_CONTROL_CITAS
        WHERE id_hd = ? AND idTecnicoAsi = ?
        """
        try:
            rows = self.db.select(query, (id_hd, self.calidad_fase_id))
        except Exception as e:
            raise DatabaseError(detail=str(e))

        if not rows:
            raise NotFoundError(detail=f"id_hd={id_hd} no está en fase de calidad")

        return [CalidadSchema.db_to_model(row) for row in rows]

    # ============================================================
    # 3. Obtener una calidad por ID (id = PK)
    # ============================================================
    def get_calidad_por_id(self, id: int) -> CalidadModel:
        query = """
        SELECT *
        FROM TYT_LV_TBL_CONTROL_CITAS
        WHERE id = ?
        """
        try:
            rows = self.db.select(query, (id,))
        except Exception as e:
            raise DatabaseError(detail=str(e))

        if not rows:
            raise NotFoundError(detail=f"id={id}")

        return CalidadSchema.db_to_model(rows[0])

    # ============================================================
    # 4. Obtener info del vehículo en fase anterior
    # ============================================================
    def get_vehiculo_info(self, id_hd: int) -> CalidadModel:
        query = """
        SELECT *
        FROM TYT_LV_TBL_CONTROL_CITAS
        WHERE id_hd = ? AND (idTecnicoAsi = ? OR idTecnicoAsi = ?)
        """
        try:
            rows = self.db.select(
                query, (id_hd, self.previus_fase_id, self.calidad_fase_id)
            )
        except Exception as e:
            raise DatabaseError(detail=str(e))

        if not rows:
            raise NotFoundError(detail=f"id_hd={id_hd} no está en fase previa")

        return CalidadSchema.db_to_model(rows[0])

    # ============================================================
    # 5. Obtener comentarios por idChip
    # ============================================================
    def get_comentarios(self, id_chip: int) -> List[CalidadComentarioModel]:
        query = """
        SELECT *
        FROM TYT_LV_TBL_CONTROL_CITAS_COM
        WHERE idChip = ?
        ORDER BY fecha ASC, idLinea ASC
        """
        try:
            rows = self.db.select(query, (id_chip,))
        except Exception as e:
            raise DatabaseError(detail=str(e))

        return [ComentarioSchema.db_to_model(row) for row in rows]

    # ============================================================
    # 6. Insertar comentario con idLinea incremental
    # ============================================================
    def agregar_comentario(self, data: CrearComentario) -> CalidadComentarioModel:

        # ======================
        # VALIDACIONES
        # ======================
        if not data.comentario or len(data.comentario.strip()) == 0:
            raise ValidationError(detail="El comentario no puede estar vacío")

        # ======================
        # OBTENER SIGUIENTE idLinea
        # ======================
        next_line_query = """
        SELECT ISNULL(MAX(idLinea), 0) + 1 AS next_line
        FROM TYT_LV_TBL_CONTROL_CITAS_COM
        WHERE idChip = ?
        """

        try:
            res = self.db.select(next_line_query, (data.id_chip,))
            next_line = res[0]["next_line"]
        except Exception as e:
            raise DatabaseError(detail=f"No se pudo obtener idLinea: {str(e)}")

        # ======================
        # INSERTAR COMENTARIO
        # ======================
        insert_query = """
        INSERT INTO TYT_LV_TBL_CONTROL_CITAS_COM
        (idChip, fecha, Status, cveUsuario, idLinea, Comentario)
        VALUES (?, GETDATE(), ?, ?, ?, ?)
        """

        try:
            self.db.insert(
                insert_query,
                (
                    data.id_chip,
                    data.status,
                    data.cve_usuario,
                    next_line,
                    data.comentario,
                ),
            )
        except Exception as e:
            raise DatabaseError(detail=f"Error al insertar comentario: {str(e)}")

        # ======================
        # RECUPERAR REGISTRO INSERTADO
        # ======================
        select_query = """
        SELECT *
        FROM TYT_LV_TBL_CONTROL_CITAS_COM
        WHERE idChip = ? AND idLinea = ?
        """
        try:
            row = self.db.select(select_query, (data.id_chip, next_line))[0]
        except Exception as e:
            raise DatabaseError(detail=str(e))

        return ComentarioSchema.db_to_model(row)

    # ============================================================
    # 7. INICIAR CALIDAD
    # ============================================================
    def iniciar_calidad(self, id: int, usuario: str) -> CalidadModel:
        # 1. Obtener el registro
        calidad = self.get_calidad_por_id(id)

        # Validación: ya iniciada
        if calidad.fecha_hora_ini_oper is not None:
            raise ValidationError(detail="La calidad ya fue iniciada.")

        # 2. Actualizar DB
        update_query = """
        UPDATE TYT_LV_TBL_CONTROL_CITAS
        SET 
            fecha_Hora_ini_Oper = GETDATE(),
            Status = 'INICIADA'
        WHERE id = ?
        """

        try:
            self.db.update(update_query, (id,))
        except Exception as e:
            raise DatabaseError(detail=f"No se pudo iniciar la calidad: {str(e)}")

        # 3. Insertar comentario automático
        auto_comment = CrearComentario(
            id_chip=calidad.id_chip,
            status="INICIADA",
            cve_usuario=usuario,
            comentario="Calidad iniciada.",
        )
        self.agregar_comentario(auto_comment)

        # 4. Devolver la calidad actualizada
        return self.get_calidad_por_id(id)

    # ============================================================
    # 8. FINALIZAR CALIDAD
    # ============================================================
    def finalizar_calidad(self, id: int, usuario: str) -> CalidadModel:
        # 1. Obtener el registro
        calidad = self.get_calidad_por_id(id)

        if calidad.fecha_hora_ini_oper is None:
            raise ValidationError(
                detail="No se puede finalizar una calidad que no ha sido iniciada."
            )

        if calidad.fecha_hora_fin_oper is not None:
            raise ValidationError(detail="La calidad ya está finalizada.")

        # 2. Actualizar DB
        update_query = """
        UPDATE TYT_LV_TBL_CONTROL_CITAS
        SET 
            Fecha_Hora_Fin_Oper = GETDATE(),
            Status = 'TERMINADO'
        WHERE id = ?
        """

        try:
            self.db.update(update_query, (id,))
        except Exception as e:
            raise DatabaseError(detail=f"No se pudo finalizar la calidad: {str(e)}")

        # 3. Insertar comentario automático
        auto_comment = CrearComentario(
            id_chip=calidad.id_chip,
            status="TERMINADO",
            cve_usuario=usuario,
            comentario="Calidad finalizada.",
        )
        self.agregar_comentario(auto_comment)

        # 4. Devolver la calidad actualizada
        return self.get_calidad_por_id(id)
