# Backend - API Tablero HYP Calidad

API REST desarrollada con FastAPI para el sistema de gestión de calidad de vehículos.

## 🛠️ Tecnologías

- **Framework**: FastAPI 0.121.2
- **Base de datos**: SQL Server (via pyodbc)
- **Validación**: Pydantic 2.12.4
- **Servidor**: Uvicorn 0.38.0
- **Python**: 3.x

## 📁 Estructura del Proyecto

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # Punto de entrada de la aplicación
│   ├── api/                    # Endpoints generales
│   ├── core/                   # Configuración y utilidades
│   │   ├── config.py          # Configuración de la aplicación
│   │   └── db.py              # Conexión a base de datos
│   ├── errors/                # Sistema de manejo de errores
│   │   ├── error_catalog.py  # Catálogo de errores
│   │   ├── error_handlers.py # Handlers personalizados
│   │   └── errors.py         # Definición de errores
│   └── modules/               # Módulos de negocio
│       └── calidad/           # Módulo de calidad
│           ├── calidad_model.py       # Modelos de datos
│           ├── calidad_router.py      # Endpoints
│           ├── calidad_schema.py      # Schemas de BD
│           ├── calidad_schema_api.py  # Schemas de API
│           └── calidad_service.py     # Lógica de negocio
├── requirements.txt
└── README.md
```

## 🚀 Instalación

### Prerrequisitos

- Python 3.8 o superior
- SQL Server
- ODBC Driver 17 for SQL Server

### Pasos de instalación

1. **Clonar el repositorio y navegar a la carpeta backend**

   ```bash
   cd backend
   ```

2. **Crear un entorno virtual (recomendado)**

   ```bash
   python -m venv venv
   venv\Scripts\activate  # En Windows
   # source venv/bin/activate  # En Linux/Mac
   ```

3. **Instalar dependencias**

   ```bash
   pip install -r requirements.txt
   ```

4. **Configurar variables de entorno**

   Crear un archivo `.env` en la carpeta `backend/` con el siguiente contenido:

   ```env
   # Base de datos
   DB_SERVER=tu_servidor
   DB_USER=tu_usuario
   DB_PASSWORD=tu_contraseña
   DB_NAME=nombre_base_datos
   DB_DRIVER=ODBC Driver 17 for SQL Server

   # Configuración de fases (Tabla HypFases en la db de Tableros hyp)
   CALIDAD_FASE_ID=id_fase_calidad
   PREVIUS_FASE_ID=id_fase_anterior

   # CORS (opcional)
   CORS_ORIGINS=["http://localhost:3000"]

   # Proyecto (opcional)
   PROJECT_NAME=Tablero HYP Calidad
   VERSION=1.0.0
   ```

5. **Ejecutar la aplicación**

   ```bash
   uvicorn app.main:app --reload
   ```

   La API estará disponible en: `http://localhost:8000`

## 📡 API Endpoints

### Health Check

- `GET /` - Verificar estado de la API

### Autenticación

- `GET /api/calidad/auth/me/` - Verificar autenticación

### Vehículos

- `GET /api/calidad/` - Listar vehículos en fase de calidad
- `GET /api/calidad/vehiculo/{id_hd}/` - Obtener vehículo por ID HD
- `GET /api/calidad/item/{id}/` - Obtener calidad por ID (PK)

### Comentarios

- `GET /api/calidad/{calidad_id}/comentarios/` - Listar comentarios de una calidad
- `POST /api/calidad/{calidad_id}/comentarios/` - Crear comentario

### Acciones

- `POST /api/calidad/aprobar/` - Aprobar vehículo
- `POST /api/calidad/rechazar/` - Rechazar vehículo

## 📚 Documentación Interactiva

Una vez iniciada la aplicación, puedes acceder a:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

## 🏗️ Arquitectura

### Estructura por capas

1. **Router Layer** (`*_router.py`): Define los endpoints y valida las peticiones
2. **Service Layer** (`*_service.py`): Contiene la lógica de negocio
3. **Model Layer** (`*_model.py`): Maneja el acceso a datos
4. **Schema Layer** (`*_schema.py`, `*_schema_api.py`): Define estructuras de datos

### Sistema de Errores

El proyecto implementa un sistema de manejo de errores centralizado:

- **AppError**: Clase base para errores personalizados
- **ErrorCatalog**: Catálogo de errores predefinidos
- **Error Handlers**: Manejadores que transforman errores en respuestas HTTP

## 🔧 Desarrollo

### Agregar un nuevo módulo

1. Crear una carpeta en `app/modules/nombre_modulo/`
2. Crear los archivos base:
   - `nombre_modulo_router.py` - Endpoints
   - `nombre_modulo_service.py` - Lógica de negocio
   - `nombre_modulo_model.py` - Acceso a datos
   - `nombre_modulo_schema.py` - Schemas de BD
   - `nombre_modulo_schema_api.py` - Schemas de API
3. Registrar el router en `app/main.py`:
   ```python
   from app.modules.nombre_modulo.nombre_modulo_router import router as nombre_modulo_router
   app.include_router(nombre_modulo_router, prefix="/api")
   ```

### Buenas prácticas

- Usar Pydantic para validación de datos
- Implementar manejo de errores apropiado
- Documentar endpoints con docstrings
- Seguir la estructura de capas establecida
- Usar type hints en Python

## 🗄️ Base de Datos

El proyecto utiliza SQL Server con pyodbc. La conexión se configura en `app/core/db.py`.

### Parámetros de conexión

Los parámetros se cargan desde variables de entorno:

- `DB_SERVER`: Servidor de base de datos
- `DB_USER`: Usuario de base de datos
- `DB_PASSWORD`: Contraseña
- `DB_NAME`: Nombre de la base de datos
- `DB_DRIVER`: Driver ODBC (por defecto: ODBC Driver 17 for SQL Server)

## 🧪 Testing

```bash
# Ejecutar tests (cuando estén implementados)
pytest
```

## 🚀 Despliegue

Para despliegue en producción:

1. Configurar las variables de entorno apropiadas
2. Usar un servidor ASGI como Uvicorn o Gunicorn
3. Configurar un proxy reverso (Nginx, Apache)
4. Asegurar la conexión SSL/TLS

```bash
# Ejemplo con Uvicorn en producción
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

## 📝 Variables de Entorno

| Variable          | Descripción                   | Requerido | Default                       |
| ----------------- | ----------------------------- | --------- | ----------------------------- |
| `DB_SERVER`       | Servidor de base de datos     | Sí        | -                             |
| `DB_USER`         | Usuario de BD                 | Sí        | -                             |
| `DB_PASSWORD`     | Contraseña de BD              | Sí        | -                             |
| `DB_NAME`         | Nombre de la BD               | Sí        | -                             |
| `DB_DRIVER`       | Driver ODBC                   | No        | ODBC Driver 17 for SQL Server |
| `CALIDAD_FASE_ID` | ID de fase de calidad         | Sí        | -                             |
| `PREVIUS_FASE_ID` | ID de fase anterior           | Sí        | -                             |
| `CORS_ORIGINS`    | Orígenes permitidos para CORS | No        | ["*"]                         |
| `PROJECT_NAME`    | Nombre del proyecto           | No        | Tablero HYP Calidad           |
| `VERSION`         | Versión de la API             | No        | 1.0.0                         |

## 📄 Licencia

Este proyecto es propiedad de CAPNET.

## 👥 Autores

Equipo de desarrollo CAPNET
