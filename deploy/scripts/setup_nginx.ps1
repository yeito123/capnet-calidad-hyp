# ============================================================
# Script de configuración de IIS como proxy reverso
# ============================================================

param($config)

. "$PSScriptRoot\utils.ps1"

Write-Step "Configurando IIS como proxy reverso..."

# Validar privilegios de administrador
if (!(Test-Administrator)) {
    Write-Error-Custom "Este script requiere privilegios de administrador"
    exit 1
}

$iisTarget = $config.iis_target
$backendPort = $config.backend_port
$siteName = "CalidadHYP"
$appPoolName = "CalidadHYPPool"

# Validar que IIS está instalado
try {
    Import-Module WebAdministration -ErrorAction Stop
    Write-Success "IIS está instalado"
}
catch {
    Write-Error-Custom "IIS no está instalado o no se puede cargar el módulo WebAdministration"
    Write-Host "Instala IIS desde: Panel de Control > Programas > Activar o desactivar características de Windows" -ForegroundColor Yellow
    exit 1
}

# Verificar que URL Rewrite está instalado
$urlRewrite = Get-WindowsOptionalFeature -Online -FeatureName IIS-URLRewrite -ErrorAction SilentlyContinue
if (!$urlRewrite -or $urlRewrite.State -ne "Enabled") {
    Write-Warning-Custom "URL Rewrite Module no está instalado"
    Write-Host "Descarga desde: https://www.iis.net/downloads/microsoft/url-rewrite" -ForegroundColor Yellow
    Write-Host "Es necesario para el funcionamiento del proxy reverso" -ForegroundColor Yellow
}

# Verificar que ARR está instalado
$arrModule = Get-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.webServer/proxy" -Name "enabled" -ErrorAction SilentlyContinue
if (!$arrModule) {
    Write-Warning-Custom "Application Request Routing (ARR) no está instalado"
    Write-Host "Descarga desde: https://www.iis.net/downloads/microsoft/application-request-routing" -ForegroundColor Yellow
    Write-Host "Es necesario para el funcionamiento del proxy reverso" -ForegroundColor Yellow
}
else {
    # Habilitar proxy en ARR si no está habilitado
    if ($arrModule.Value -eq $false) {
        Write-Step "Habilitando proxy en ARR..."
        Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.webServer/proxy" -Name "enabled" -Value $true
        Write-Success "Proxy habilitado en ARR"
    }
}

# Crear Application Pool si no existe
Write-Step "Configurando Application Pool..."

if (!(Test-Path "IIS:\AppPools\$appPoolName")) {
    New-WebAppPool -Name $appPoolName
    Write-Success "Application Pool '$appPoolName' creado"
}
else {
    Write-Success "Application Pool '$appPoolName' ya existe"
}

# Configurar Application Pool
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "managedRuntimeVersion" -Value ""
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "startMode" -Value "AlwaysRunning"
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "processModel.idleTimeout" -Value ([TimeSpan]::FromMinutes(0))
Write-Success "Application Pool configurado"

# Crear sitio web si no existe
Write-Step "Configurando sitio web en IIS..."

$site = Get-Website -Name $siteName -ErrorAction SilentlyContinue
if (!$site) {
    # Detener sitio por defecto si está usando el puerto 80
    $defaultSite = Get-Website -Name "Default Web Site" -ErrorAction SilentlyContinue
    if ($defaultSite -and $defaultSite.State -eq "Started") {
        Write-Step "Deteniendo 'Default Web Site'..."
        Stop-Website -Name "Default Web Site"
    }
    
    # Crear nuevo sitio
    New-Website -Name $siteName -PhysicalPath $iisTarget -Port 80 -ApplicationPool $appPoolName -Force
    Write-Success "Sitio web '$siteName' creado"
}
else {
    Write-Success "Sitio web '$siteName' ya existe"
    
    # Actualizar configuración
    Set-ItemProperty "IIS:\Sites\$siteName" -Name "physicalPath" -Value $iisTarget
    Set-ItemProperty "IIS:\Sites\$siteName" -Name "applicationPool" -Value $appPoolName
}

# Asegurar que el sitio está iniciado
Start-Website -Name $siteName -ErrorAction SilentlyContinue
Write-Success "Sitio web iniciado"

# Crear web.config con configuración de proxy
Write-Step "Configurando web.config para proxy reverso..."

$webConfigPath = "$iisTarget\web.config"
$webConfigContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <!-- Proxy para API Backend -->
                <rule name="API Proxy" stopProcessing="true">
                    <match url="^api/(.*)" />
                    <action type="Rewrite" url="http://localhost:$backendPort/api/{R:1}" />
                    <serverVariables>
                        <set name="HTTP_X_ORIGINAL_HOST" value="{HTTP_HOST}" />
                        <set name="HTTP_X_FORWARDED_FOR" value="{REMOTE_ADDR}" />
                        <set name="HTTP_X_FORWARDED_PROTO" value="{HTTPS}" />
                    </serverVariables>
                </rule>
                
                <!-- Proxy para Next.js (Frontend) -->
                <rule name="Next.js Proxy" stopProcessing="true">
                    <match url="calidad-hyp/(.*)" />
                    <conditions>
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="http://localhost:3000/calidad-hyp/{R:1}" />
                    <serverVariables>
                        <set name="HTTP_X_ORIGINAL_HOST" value="{HTTP_HOST}" />
                    </serverVariables>
                </rule>
            </rules>
        </rewrite>
        
        <!-- Habilitar WebSocket para Next.js HMR -->
        <webSocket enabled="true" />
        
        <!-- Headers de seguridad -->
        <httpProtocol>
            <customHeaders>
                <add name="X-Content-Type-Options" value="nosniff" />
                <add name="X-Frame-Options" value="SAMEORIGIN" />
                <add name="X-XSS-Protection" value="1; mode=block" />
            </customHeaders>
        </httpProtocol>
        
        <!-- Configuración de compresión -->
        <urlCompression doStaticCompression="true" doDynamicCompression="true" />
        
        <!-- Tamaño máximo de request (30MB para uploads) -->
        <security>
            <requestFiltering>
                <requestLimits maxAllowedContentLength="31457280" />
            </requestFiltering>
        </security>
    </system.webServer>
</configuration>
"@

# Backup del web.config anterior si existe
if (Test-Path $webConfigPath) {
    Backup-File -FilePath $webConfigPath
}

Set-Content -Path $webConfigPath -Value $webConfigContent -Encoding UTF8
Write-Success "web.config creado/actualizado"

# Dar permisos al directorio
Write-Step "Configurando permisos..."

$acl = Get-Acl $iisTarget
$permission = "IIS_IUSRS", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $iisTarget $acl

Write-Success "Permisos configurados"

# Reiniciar el sitio
Write-Step "Reiniciando sitio web..."
Stop-Website -Name $siteName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Website -Name $siteName
Write-Success "Sitio reiniciado"

# Verificar configuración
Write-Step "Verificando configuración..."

$site = Get-Website -Name $siteName
if ($site.State -eq "Started") {
    Write-Success "Sitio web está corriendo"
    Write-Host "`nURL del sitio: http://localhost/calidad-hyp/" -ForegroundColor Green
    Write-Host "URL de la API: http://localhost/api/" -ForegroundColor Green
}
else {
    Write-Error-Custom "El sitio no se inició correctamente"
    exit 1
}

Write-Success "Configuración de IIS completada"
Write-Host "`nComandos útiles de IIS:" -ForegroundColor Yellow
Write-Host "  Listar sitios:      Get-Website" -ForegroundColor Gray
Write-Host "  Ver estado:         Get-Website -Name $siteName" -ForegroundColor Gray
Write-Host "  Detener sitio:      Stop-Website -Name $siteName" -ForegroundColor Gray
Write-Host "  Iniciar sitio:      Start-Website -Name $siteName" -ForegroundColor Gray
Write-Host "  Reiniciar sitio:    Restart-WebAppPool -Name $appPoolName" -ForegroundColor Gray
Write-Host "  Ver logs:           Get-ChildItem IIS:\Sites\$siteName\Logs" -ForegroundColor Gray

