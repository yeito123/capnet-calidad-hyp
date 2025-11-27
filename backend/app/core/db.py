import pyodbc
from app.core.config import settings


class DB:
    @staticmethod
    def _connect():
        conn_str = (
            f"DRIVER={{{settings.DB_DRIVER}}};"
            f"SERVER={settings.DB_SERVER};"
            f"DATABASE={settings.DB_NAME};"
            f"UID={settings.DB_USER};"
            f"PWD={settings.DB_PASSWORD};"
            "TrustServerCertificate=yes;"
        )
        return pyodbc.connect(conn_str)

    # ----------------------------------------
    # SELECT seguro
    # ----------------------------------------
    @staticmethod
    def select(query: str, params: tuple = ()):
        conn = DB._connect()
        cursor = conn.cursor()
        cursor.execute(query, params)
        rows = cursor.fetchall()

        # Convertir a dicts automáticamente
        columns = [column[0] for column in cursor.description]
        result = [dict(zip(columns, row)) for row in rows]

        conn.close()
        return result

    # ----------------------------------------
    # INSERT seguro (returns last ID si aplica)
    # ----------------------------------------
    @staticmethod
    def insert(query: str, params: tuple):
        conn = DB._connect()
        cursor = conn.cursor()
        cursor.execute(query, params)
        conn.commit()

        try:
            cursor.execute("SELECT SCOPE_IDENTITY()")
            last_id = cursor.fetchone()[0]
        except:
            last_id = None

        conn.close()
        return last_id

    # ----------------------------------------
    # UPDATE seguro
    # ----------------------------------------
    @staticmethod
    def update(query: str, params: tuple):
        conn = DB._connect()
        cursor = conn.cursor()
        cursor.execute(query, params)
        conn.commit()

        affected = cursor.rowcount
        conn.close()
        return affected

    # ----------------------------------------
    # DELETE seguro
    # ----------------------------------------
    @staticmethod
    def delete(query: str, params: tuple):
        conn = DB._connect()
        cursor = conn.cursor()
        cursor.execute(query, params)
        conn.commit()

        affected = cursor.rowcount
        conn.close()
        return affected
