# ============================================================
# Script de instalación del Backend (FastAPI)
# ============================================================

param($config)

. "$PSScriptRoot\utils.ps1"

Write-Step "Instalando Backend (FastAPI)..."

$backendPath = $config.backend_path
$port = $config.backend_port
$venvPath = "$backendPath\venv"
$requirementsPath = "$backendPath\requirements.txt"
$envPath = "$backendPath\.env"

# Validar que existe el directorio del backend
if (!(Test-Path $backendPath)) {
    Write-Error-Custom "No se encuentra el directorio del backend: $backendPath"
    exit 1
}

# Validar que Python está instalado
if (!(Test-CommandExists "python")) {
    Write-Error-Custom "Python no está instalado o no está en el PATH"
    exit 1
}

# Mostrar versión de Python
$pythonVersion = python --version
Write-Host "Versión de Python: $pythonVersion" -ForegroundColor Gray

# Cambiar al directorio del backend
Set-Location $backendPath

# Crear entorno virtual si no existe
if (!(Test-Path $venvPath)) {
    Write-Step "Creando entorno virtual de Python..."
    python -m venv $venvPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Error al crear el entorno virtual"
        exit 1
    }
    Write-Success "Entorno virtual creado"
}
else {
    Write-Warning-Custom "El entorno virtual ya existe"
}

# Activar entorno virtual
Write-Step "Activando entorno virtual..."
$activateScript = "$venvPath\Scripts\Activate.ps1"

if (Test-Path $activateScript) {
    & $activateScript
    Write-Success "Entorno virtual activado"
}
else {
    Write-Error-Custom "No se encuentra el script de activación"
    exit 1
}

# Actualizar pip
Write-Step "Actualizando pip..."
python -m pip install --upgrade pip --quiet

# Instalar dependencias
if (Test-Path $requirementsPath) {
    Write-Step "Instalando dependencias desde requirements.txt..."
    pip install -r $requirementsPath --quiet
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Error al instalar dependencias"
        exit 1
    }
    Write-Success "Dependencias instaladas correctamente"
}
else {
    Write-Error-Custom "No se encuentra requirements.txt en $requirementsPath"
    exit 1
}

# Verificar que uvicorn está instalado
Write-Step "Verificando instalación de Uvicorn..."
$uvicornPath = "$venvPath\Scripts\uvicorn.exe"
if (Test-Path $uvicornPath) {
    Write-Success "Uvicorn instalado correctamente"
}
else {
    Write-Error-Custom "Uvicorn no está instalado"
    exit 1
}

# Crear archivo .env si no existe
if (!(Test-Path $envPath)) {
    Write-Step "Creando archivo .env de ejemplo..."
    
    $envContent = @"
# Base de datos
DB_SERVER=tu_servidor
DB_USER=tu_usuario
DB_PASSWORD=tu_contraseña
DB_NAME=nombre_base_datos
DB_DRIVER=ODBC Driver 17 for SQL Server

# Configuración de fases
CALIDAD_FASE_ID=1
PREVIUS_FASE_ID=0

# CORS
CORS_ORIGINS=["http://localhost:3000"]

# Proyecto
PROJECT_NAME=Tablero HYP Calidad
VERSION=1.0.0
"@
    
    Set-Content -Path $envPath -Value $envContent -Encoding UTF8
    Write-Warning-Custom "Archivo .env creado. DEBES configurar las variables antes de ejecutar el backend"
}
else {
    Write-Success "Archivo .env ya existe"
}

# Verificar ODBC Driver
Write-Step "Verificando ODBC Driver para SQL Server..."
$odbcDrivers = Get-OdbcDriver | Where-Object { $_.Name -like "*SQL Server*" }
if ($odbcDrivers) {
    Write-Success "ODBC Driver encontrado: $($odbcDrivers[0].Name)"
}
else {
    Write-Warning-Custom "No se encontró ODBC Driver 17 for SQL Server. Puede ser necesario instalarlo."
}

Write-Success "Backend instalado correctamente"
Write-Host "`nPara ejecutar el backend manualmente:" -ForegroundColor Gray
Write-Host "  cd $backendPath" -ForegroundColor Gray
Write-Host "  .\venv\Scripts\activate" -ForegroundColor Gray
Write-Host "  uvicorn app.main:app --reload" -ForegroundColor Gray


