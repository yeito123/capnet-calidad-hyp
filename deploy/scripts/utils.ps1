# ============================================================
# Funciones de utilidad para scripts de despliegue
# ============================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Stop-ServiceIfExists {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -eq 'Running') {
            Write-Step "Deteniendo servicio $ServiceName..."
            Stop-Service -Name $ServiceName -Force
            Write-Success "Servicio detenido"
        }
        return $true
    }
    return $false
}

function Invoke-WithRetry {
    param(
        [ScriptBlock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 2
    )
    
    $attempt = 1
    while ($attempt -le $MaxRetries) {
        try {
            & $ScriptBlock
            return $true
        }
        catch {
            if ($attempt -eq $MaxRetries) {
                throw
            }
            Write-Warning-Custom "Intento $attempt falló. Reintentando en $DelaySeconds segundos..."
            Start-Sleep -Seconds $DelaySeconds
            $attempt++
        }
    }
    return $false
}

function Backup-File {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$FilePath.backup_$timestamp"
        Copy-Item -Path $FilePath -Destination $backupPath -Force
        Write-Success "Backup creado: $backupPath"
        return $backupPath
    }
    return $null
}

function New-EnvFile {
    param(
        [string]$Path,
        [hashtable]$Variables
    )
    
    $content = ""
    foreach ($key in $Variables.Keys) {
        $value = $Variables[$key]
        $content += "$key=$value`n"
    }
    
    Set-Content -Path $Path -Value $content -Encoding UTF8
    Write-Success "Archivo .env creado: $Path"
}

function Test-Port {
    param([int]$Port)
    
    $connection = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue
    return $connection.TcpTestSucceeded
}

function Wait-ForPort {
    param(
        [int]$Port,
        [int]$TimeoutSeconds = 30
    )
    
    $elapsed = 0
    while ($elapsed -lt $TimeoutSeconds) {
        if (Test-Port -Port $Port) {
            return $true
        }
        Start-Sleep -Seconds 1
        $elapsed++
    }
    return $false
}
