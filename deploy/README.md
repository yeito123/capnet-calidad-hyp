# Despliegue Calidad-HYP

Scripts automatizados de despliegue para la aplicación Calidad-HYP en Windows.

## Descripción General

Este conjunto de despliegue automatiza la instalación y configuración de:

- **Backend**: Aplicación FastAPI ejecutándose en Uvicorn
- **Frontend**: Aplicación Next.js servida vía IIS
- **Nginx**: Proxy inverso para enrutamiento de API
- **Servicio de Windows**: API Backend como servicio persistente de Windows usando NSSM

## Prerequisitos

- Python 3.x con pip
- Node.js y npm
- IIS (Internet Information Services)
- Nginx para Windows
- NSSM (Non-Sucking Service Manager)
- Git

## Configuración

Edita `config.json` para que coincida con tu entorno:

```json
{
  "backend_path": "D:/capnet/capnet_calidad_hyp/backend",
  "frontend_path": "D:/capnet/capnet_calidad_hyp/frontend/calidad-hyp",
  "iis_target": "C:/inetpub/wwwroot/calidad-hyp",
  "nginx_path": "C:/nginx/nginx.exe",
  "nssm_path": "C:/nssm/nssm.exe",
  "service_name": "CalidadHYPAPI",
  "backend_port": 8000
}
```

### Parámetros de Configuración

- **backend_path**: Ruta completa al directorio de la aplicación backend
- **frontend_path**: Ruta completa a la aplicación frontend Next.js
- **iis_target**: Destino webroot de IIS para el build del frontend
- **nginx_path**: Ruta a nginx.exe
- **nssm_path**: Ruta a nssm.exe (gestor de servicios)
- **service_name**: Nombre para el servicio de Windows
- **backend_port**: Puerto para la API backend (predeterminado: 8000)

## Instalación

Ejecuta el script principal de instalación desde PowerShell con privilegios de administrador:

```powershell
.\install.ps1
```

Esto ejecutará los siguientes pasos en orden:

1. **Actualizar Repositorio**: Obtener los últimos cambios desde Git
2. **Configuración Backend**: Crear entorno virtual e instalar dependencias
3. **Build Frontend**: Instalar paquetes npm, compilar y desplegar en IIS
4. **Configuración Nginx**: Configurar proxy inverso para enrutamiento de API
5. **Configuración de Servicio**: Instalar backend como servicio de Windows

## Scripts Individuales

También puedes ejecutar scripts de despliegue individuales según sea necesario:

### Instalación del Backend

```powershell
.\scripts\install_backend.ps1 (Get-Content .\config.json | ConvertFrom-Json)
```

- Crea entorno virtual de Python en `backend/venv`
- Instala todos los requisitos de `requirements.txt`

### Instalación del Frontend

```powershell
.\scripts\install_frontend.ps1 (Get-Content .\config.json | ConvertFrom-Json)
```

- Instala dependencias npm
- Compila y exporta la aplicación Next.js
- Copia la salida de compilación al directorio de IIS

### Configuración de Nginx

```powershell
.\scripts\setup_nginx.ps1 (Get-Content .\config.json | ConvertFrom-Json)
```

- Configura nginx como proxy inverso
- Enruta peticiones `/api/` hacia el backend
- Reinicia el servicio nginx

### Configuración del Servicio

```powershell
.\scripts\setup_service.ps1 (Get-Content .\config.json | ConvertFrom-Json)
```

- Instala backend como servicio de Windows usando NSSM
- Configura Uvicorn para ejecutarse al inicio del sistema
- Inicia el servicio

## Arquitectura

```
Petición del Cliente
    ↓
Nginx (:80)
    ↓
    ├─→ /api/* → Backend (Uvicorn :8000)
    └─→ /* → Frontend (IIS)
```

- **Frontend**: Archivos estáticos servidos por IIS en `C:/inetpub/wwwroot/calidad-hyp`
- **Backend**: Aplicación FastAPI ejecutándose como servicio de Windows en el puerto 8000
- **Nginx**: Escucha en el puerto 80, redirige peticiones API al backend

## Gestión del Servicio

### Verificar Estado del Servicio

```powershell
Get-Service CalidadHYPAPI
```

### Detener Servicio

```powershell
Stop-Service CalidadHYPAPI
```

### Iniciar Servicio

```powershell
Start-Service CalidadHYPAPI
```

### Eliminar Servicio

```powershell
C:/nssm/nssm.exe remove CalidadHYPAPI confirm
```

## Solución de Problemas

### El Servicio Backend No Inicia

- Verifica que el entorno virtual de Python existe en `backend/venv`
- Verifica que el puerto 8000 no esté en uso
- Revisa los logs del servicio: `C:/nssm/nssm.exe get CalidadHYPAPI`

### Problemas con Nginx

- Verifica la sintaxis de nginx.conf: `C:/nginx/nginx.exe -t`
- Verifica si el proceso nginx está ejecutándose: `Get-Process nginx`
- Revisa los logs de error de nginx en `C:/nginx/logs/error.log`

### El Frontend No Carga

- Verifica que IIS está ejecutándose y sirviendo desde el directorio correcto
- Verifica que los archivos de compilación existen en `C:/inetpub/wwwroot/calidad-hyp`
- Asegura que el pool de aplicaciones de IIS esté iniciado

## Actualizar la Aplicación

Para actualizar la aplicación con los últimos cambios:

```powershell
.\install.ps1
```

Esto hará:

1. Obtener el último código del repositorio
2. Recompilar backend y frontend
3. Reiniciar servicios

## Notas

- Ejecuta todos los scripts con privilegios de Administrador
- Asegura que todas las rutas en `config.json` usen barras diagonales o barras invertidas escapadas
- El script de instalación asume que el repositorio ya está clonado
- El servicio backend se ejecuta en el entorno virtual en `backend/venv`

## Estructura de Archivos

```
deploy/
├── config.json              # Archivo de configuración
├── install.ps1              # Script principal de instalación
├── README.md                # Este archivo
└── scripts/
    ├── install_backend.ps1  # Configuración del backend
    ├── install_fronend.ps1  # Compilación y despliegue del frontend
    ├── setup_nginx.ps1      # Configuración de Nginx
    ├── setup_service.ps1    # Configuración del servicio de Windows
    └── utils.ps1            # Funciones utilitarias (actualmente sin usar)
```
