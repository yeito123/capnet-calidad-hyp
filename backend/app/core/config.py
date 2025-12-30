from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    DB_SERVER: str
    DB_USER: str
    DB_PASSWORD: str
    DB_NAME: str
    DB_DRIVER: str = "ODBC Driver 17 for SQL Server"
    CALIDAD_FASE_ID: int
    PREVIUS_FASE_ID: int

    # Lee CSV desde .env: "http://a,http://b"
    CORS_ORIGINS: list[str] = Field(default_factory=list)

    PROJECT_NAME: str = "Tablero HYP Calidad"
    VERSION: str = "1.0.0"

    class Config:
        env_file = ".env"

settings = Settings()
