# ============================================================
# Script principal de instalación - Calidad HYP
# ============================================================

param(
    [switch]$SkipGitPull,
    [switch]$BackendOnly,
    [switch]$FrontendOnly,
    [switch]$ServiceOnly
)

$ErrorActionPreference = "Stop"

# Importar utilidades
. "$PSScriptRoot\scripts\utils.ps1"

Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     INSTALADOR CALIDAD-HYP                                ║
║     Sistema de Gestión de Calidad de Vehículos           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# Validar privilegios de administrador
if (!(Test-Administrator)) {
    Write-Error-Custom "Este script requiere privilegios de administrador"
    Write-Host "`nEjecuta PowerShell como Administrador y vuelve a intentar" -ForegroundColor Yellow
    exit 1
}

# Cargar configuración
$configPath = "$PSScriptRoot\config.json"
if (!(Test-Path $configPath)) {
    Write-Error-Custom "No se encuentra el archivo de configuración: $configPath"
    exit 1
}

Write-Step "Cargando configuración..."
try {
    $config = Get-Content $configPath | ConvertFrom-Json
    Write-Success "Configuración cargada correctamente"
}
catch {
    Write-Error-Custom "Error al leer el archivo de configuración"
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Mostrar configuración
Write-Host "`nConfiguración:" -ForegroundColor Yellow
Write-Host "  Backend:  $($config.backend_path)" -ForegroundColor Gray
Write-Host "  Frontend: $($config.frontend_path)" -ForegroundColor Gray
Write-Host "  IIS:      $($config.iis_target)" -ForegroundColor Gray
Write-Host "  Puerto:   $($config.backend_port)" -ForegroundColor Gray
Write-Host "  Servicio: $($config.service_name)" -ForegroundColor Gray

# Confirmar instalación
Write-Host "`n¿Continuar con la instalación? (S/N): " -NoNewline -ForegroundColor Yellow
$confirmation = Read-Host
if ($confirmation -ne 'S' -and $confirmation -ne 's') {
    Write-Host "Instalación cancelada" -ForegroundColor Yellow
    exit 0
}

# Timestamp de inicio
$startTime = Get-Date

# 1. Actualizar repositorio
if (!$SkipGitPull) {
    Write-Step "Actualizando repositorio desde Git..."
    
    $repoPath = Split-Path -Parent $PSScriptRoot
    Push-Location $repoPath
    
    try {
        if (Test-CommandExists "git") {
            git pull
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Repositorio actualizado"
            }
            else {
                Write-Warning-Custom "No se pudo actualizar el repositorio"
            }
        }
        else {
            Write-Warning-Custom "Git no está instalado. Saltando actualización del repositorio."
        }
    }
    catch {
        Write-Warning-Custom "Error al actualizar repositorio: $($_.Exception.Message)"
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Warning-Custom "Saltando actualización de Git (parámetro -SkipGitPull)"
}

# 2. Instalación del Backend
if (!$FrontendOnly) {
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Step "INSTALACIÓN DEL BACKEND (FastAPI)"
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    try {
        & "$PSScriptRoot\scripts\install_backend.ps1" $config
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Success "Backend instalado correctamente"
        }
        else {
            Write-Error-Custom "Error en la instalación del backend"
            exit 1
        }
    }
    catch {
        Write-Error-Custom "Error al ejecutar install_backend.ps1"
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

# 3. Instalación del Frontend
if (!$BackendOnly) {
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Step "INSTALACIÓN DEL FRONTEND (Next.js)"
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    try {
        & "$PSScriptRoot\scripts\install_fronend.ps1" $config
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Success "Frontend instalado correctamente"
        }
        else {
            Write-Error-Custom "Error en la instalación del frontend"
            exit 1
        }
    }
    catch {
        Write-Error-Custom "Error al ejecutar install_fronend.ps1"
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

# 4. Configuración de IIS
if (!$BackendOnly -and !$ServiceOnly) {
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Step "CONFIGURACIÓN DE IIS"
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    try {
        & "$PSScriptRoot\scripts\setup_nginx.ps1" $config
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Success "IIS configurado correctamente"
        }
        else {
            Write-Error-Custom "Error en la configuración de IIS"
            exit 1
        }
    }
    catch {
        Write-Error-Custom "Error al ejecutar setup_nginx.ps1"
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

# 5. Configuración del servicio de Windows
if (!$FrontendOnly) {
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Step "CONFIGURACIÓN DEL SERVICIO DE WINDOWS"
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    try {
        & "$PSScriptRoot\scripts\setup_service.ps1" $config
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Success "Servicio configurado correctamente"
        }
        else {
            Write-Error-Custom "Error en la configuración del servicio"
            exit 1
        }
    }
    catch {
        Write-Error-Custom "Error al ejecutar setup_service.ps1"
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

# Calcular tiempo de instalación
$endTime = Get-Date
$duration = $endTime - $startTime

# Resumen final
Write-Host "`n" + ("=" * 60) -ForegroundColor Green
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                           ║" -ForegroundColor Green
Write-Host "║     ✓ INSTALACIÓN COMPLETADA EXITOSAMENTE                ║" -ForegroundColor Green
Write-Host "║                                                           ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green

Write-Host "`nTiempo total: $($duration.ToString('mm\:ss'))" -ForegroundColor Gray

Write-Host "`n📌 URLs de acceso:" -ForegroundColor Yellow
Write-Host "  Frontend:        http://localhost/calidad-hyp/" -ForegroundColor Cyan
Write-Host "  API Backend:     http://localhost:$($config.backend_port)/" -ForegroundColor Cyan
Write-Host "  API Docs:        http://localhost:$($config.backend_port)/docs" -ForegroundColor Cyan
Write-Host "  API via Proxy:   http://localhost/api/" -ForegroundColor Cyan

Write-Host "`n📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Configura las variables de entorno en:" -ForegroundColor Gray
Write-Host "     - $($config.backend_path)\.env" -ForegroundColor Gray
Write-Host "     - $($config.frontend_path)\.env.local" -ForegroundColor Gray
Write-Host "  2. Reinicia el servicio del backend si cambiaste el .env:" -ForegroundColor Gray
Write-Host "     Restart-Service -Name $($config.service_name)" -ForegroundColor Gray
Write-Host "  3. Verifica que la aplicación esté funcionando correctamente" -ForegroundColor Gray

Write-Host "`n🔧 Comandos útiles:" -ForegroundColor Yellow
Write-Host "  Ver estado del servicio:" -ForegroundColor Gray
Write-Host "    Get-Service -Name $($config.service_name)" -ForegroundColor Cyan
Write-Host "  Ver logs del backend:" -ForegroundColor Gray
Write-Host "    Get-Content $($config.backend_path)\logs\service_output.log -Tail 50" -ForegroundColor Cyan
Write-Host "  Reiniciar IIS:" -ForegroundColor Gray
Write-Host "    Restart-WebAppPool -Name CalidadHYPPool" -ForegroundColor Cyan

Write-Host "`n"

