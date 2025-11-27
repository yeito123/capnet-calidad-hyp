# ============================================================
# Script de configuración del servicio de Windows (Backend)
# ============================================================

param($config)

. "$PSScriptRoot\utils.ps1"

Write-Step "Configurando servicio de Windows para el Backend..."

# Validar privilegios de administrador
if (!(Test-Administrator)) {
    Write-Error-Custom "Este script requiere privilegios de administrador"
    exit 1
}

$nssmPath = $config.nssm_path
$serviceName = $config.service_name
$backendPath = $config.backend_path
$port = $config.backend_port

# Validar que NSSM existe
if (!(Test-Path $nssmPath)) {
    Write-Error-Custom "NSSM no encontrado en: $nssmPath"
    Write-Host "`nDescarga NSSM desde: https://nssm.cc/download" -ForegroundColor Yellow
    exit 1
}

# Validar que existe el backend
if (!(Test-Path $backendPath)) {
    Write-Error-Custom "Directorio del backend no encontrado: $backendPath"
    exit 1
}

# Validar que existe uvicorn
$uvicornPath = "$backendPath\venv\Scripts\uvicorn.exe"
if (!(Test-Path $uvicornPath)) {
    Write-Error-Custom "Uvicorn no encontrado. Ejecuta install_backend.ps1 primero"
    exit 1
}

# Detener y eliminar servicio existente si existe
$existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Step "Eliminando servicio existente..."
    
    if ($existingService.Status -eq 'Running') {
        Stop-Service -Name $serviceName -Force
        Start-Sleep -Seconds 2
    }
    
    & $nssmPath remove $serviceName confirm
    Start-Sleep -Seconds 2
    Write-Success "Servicio existente eliminado"
}

# Crear nuevo servicio
Write-Step "Creando servicio de Windows '$serviceName'..."

$app = $uvicornPath
$appDirectory = $backendPath
$arguments = "app.main:app --host 0.0.0.0 --port $port --workers 4"

# Instalar servicio
& $nssmPath install $serviceName $app $arguments

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Error al crear el servicio"
    exit 1
}

# Configurar directorio de trabajo
& $nssmPath set $serviceName AppDirectory $appDirectory

# Configurar salida y errores
$logPath = "$backendPath\logs"
if (!(Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
}

& $nssmPath set $serviceName AppStdout "$logPath\service_output.log"
& $nssmPath set $serviceName AppStderr "$logPath\service_error.log"

# Configurar rotación de logs (10MB)
& $nssmPath set $serviceName AppStdoutCreationDisposition 4
& $nssmm set $serviceName AppStderrCreationDisposition 4
& $nssmPath set $serviceName AppRotateFiles 1
& $nssmPath set $serviceName AppRotateBytes 10485760

# Configurar inicio automático
& $nssmPath set $serviceName Start SERVICE_AUTO_START

# Configurar descripción
& $nssmPath set $serviceName Description "API Backend del Tablero HYP Calidad - FastAPI con Uvicorn"

# Configurar reinicio en caso de fallo
& $nssmPath set $serviceName AppExit Default Restart
& $nssmPath set $serviceName AppRestartDelay 5000

Write-Success "Servicio configurado correctamente"

# Iniciar servicio
Write-Step "Iniciando servicio..."

& $nssmPath start $serviceName

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Error al iniciar el servicio"
    Write-Host "Revisa los logs en: $logPath" -ForegroundColor Yellow
    exit 1
}

# Esperar y verificar que el servicio está corriendo
Start-Sleep -Seconds 3

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq 'Running') {
    Write-Success "Servicio iniciado correctamente"
    
    # Verificar que el puerto está escuchando
    Write-Step "Verificando que la API está respondiendo..."
    
    if (Wait-ForPort -Port $port -TimeoutSeconds 30) {
        Write-Success "API escuchando en puerto $port"
        
        # Intentar hacer una petición de prueba
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$port/" -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Success "API respondiendo correctamente"
            }
        }
        catch {
            Write-Warning-Custom "El servicio está corriendo pero la API no responde. Revisa los logs."
        }
    }
    else {
        Write-Warning-Custom "El servicio está corriendo pero el puerto $port no responde"
        Write-Host "Revisa los logs en: $logPath" -ForegroundColor Yellow
    }
}
else {
    Write-Error-Custom "El servicio no se inició correctamente"
    Write-Host "Revisa los logs en: $logPath" -ForegroundColor Yellow
    exit 1
}

Write-Success "Configuración del servicio completada"
Write-Host "`nComandos útiles:" -ForegroundColor Yellow
Write-Host "  Ver estado:    Get-Service -Name $serviceName" -ForegroundColor Gray
Write-Host "  Detener:       Stop-Service -Name $serviceName" -ForegroundColor Gray
Write-Host "  Iniciar:       Start-Service -Name $serviceName" -ForegroundColor Gray
Write-Host "  Reiniciar:     Restart-Service -Name $serviceName" -ForegroundColor Gray
Write-Host "  Ver logs:      Get-Content $logPath\service_output.log -Tail 50" -ForegroundColor Gray
Write-Host "  Eliminar:      $nssmPath remove $serviceName confirm" -ForegroundColor Gray

