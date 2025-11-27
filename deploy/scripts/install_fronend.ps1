# ============================================================
# Script de instalación del Frontend (Next.js)
# ============================================================

param($config)

. "$PSScriptRoot\utils.ps1"

Write-Step "Instalando Frontend (Next.js)..."

$frontendPath = $config.frontend_path
$iisTarget = $config.iis_target
$buildFolder = "$frontendPath\.next"
$envPath = "$frontendPath\.env.local"

# Validar que existe el directorio del frontend
if (!(Test-Path $frontendPath)) {
    Write-Error-Custom "No se encuentra el directorio del frontend: $frontendPath"
    exit 1
}

# Validar que Node.js está instalado
if (!(Test-CommandExists "node")) {
    Write-Error-Custom "Node.js no está instalado o no está en el PATH"
    exit 1
}

# Mostrar versiones
$nodeVersion = node --version
$npmVersion = npm --version
Write-Host "Node.js: $nodeVersion" -ForegroundColor Gray
Write-Host "npm: $npmVersion" -ForegroundColor Gray

# Cambiar al directorio del frontend
Set-Location $frontendPath

# Crear archivo .env.local si no existe
if (!(Test-Path $envPath)) {
    Write-Step "Creando archivo .env.local de ejemplo..."
    
    $backendPort = $config.backend_port
    $envContent = @"
# URL del backend
NEXT_PUBLIC_API_URL=http://localhost:$backendPort/api

# Configuración regional
NEXT_PUBLIC_DEFAULT_LOCALE=es-CO
NEXT_PUBLIC_DEFAULT_CURRENCY=COP
"@
    
    Set-Content -Path $envPath -Value $envContent -Encoding UTF8
    Write-Success "Archivo .env.local creado"
}
else {
    Write-Success "Archivo .env.local ya existe"
}

# Limpiar instalaciones anteriores
if (Test-Path "node_modules") {
    Write-Step "Limpiando node_modules existente..."
    Remove-Item -Path "node_modules" -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path ".next") {
    Write-Step "Limpiando build anterior..."
    Remove-Item -Path ".next" -Recurse -Force -ErrorAction SilentlyContinue
}

# Instalar dependencias
Write-Step "Instalando dependencias de npm..."
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Gray

npm install

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Error al instalar dependencias"
    exit 1
}
Write-Success "Dependencias instaladas correctamente"

# Build de producción
Write-Step "Generando build de producción..."
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Gray

$env:NODE_ENV = "production"
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Error al compilar la aplicación"
    exit 1
}
Write-Success "Build de producción generado"

# Verificar que el build se creó correctamente
if (!(Test-Path $buildFolder)) {
    Write-Error-Custom "No se generó la carpeta .next"
    exit 1
}

# Crear directorio de destino IIS si no existe
if (!(Test-Path $iisTarget)) {
    Write-Step "Creando directorio de destino IIS..."
    New-Item -ItemType Directory -Path $iisTarget -Force | Out-Null
    Write-Success "Directorio creado: $iisTarget"
}

# Copiar archivos necesarios para producción
Write-Step "Copiando archivos al servidor IIS..."

# Crear estructura de carpetas
$folders = @(".next", "public", "node_modules")
foreach ($folder in $folders) {
    $source = "$frontendPath\$folder"
    $dest = "$iisTarget\$folder"
    
    if (Test-Path $source) {
        Write-Host "  Copiando $folder..." -ForegroundColor Gray
        
        if (Test-Path $dest) {
            Remove-Item -Path $dest -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        Copy-Item -Path $source -Destination $dest -Recurse -Force
    }
}

# Copiar archivos de configuración
Write-Host "  Copiando archivos de configuración..." -ForegroundColor Gray
$configFiles = @("package.json", "next.config.mjs", ".env.local")
foreach ($file in $configFiles) {
    $source = "$frontendPath\$file"
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $iisTarget -Force
    }
}

Write-Success "Archivos copiados correctamente"

# Crear web.config para IIS
Write-Step "Creando configuración de IIS (web.config)..."

$webConfigContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <rule name="Next.js Proxy" stopProcessing="true">
                    <match url="(.*)" />
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
        <webSocket enabled="true" />
        <httpProtocol>
            <customHeaders>
                <add name="X-Content-Type-Options" value="nosniff" />
            </customHeaders>
        </httpProtocol>
    </system.webServer>
</configuration>
"@

$webConfigPath = "$iisTarget\web.config"
Set-Content -Path $webConfigPath -Value $webConfigContent -Encoding UTF8
Write-Success "web.config creado"

# Instalar dependencias de producción en el destino
Write-Step "Instalando dependencias de producción en IIS..."
Set-Location $iisTarget
npm install --production --quiet

if ($LASTEXITCODE -ne 0) {
    Write-Warning-Custom "Advertencia: Error al instalar dependencias de producción"
}

Write-Success "Frontend instalado correctamente en IIS"
Write-Host "`nPróximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Configurar IIS para apuntar a: $iisTarget" -ForegroundColor Gray
Write-Host "  2. Instalar URL Rewrite Module en IIS" -ForegroundColor Gray
Write-Host "  3. Instalar Application Request Routing (ARR) en IIS" -ForegroundColor Gray
Write-Host "  4. Habilitar proxy en ARR" -ForegroundColor Gray
Write-Host "`nPara ejecutar en modo desarrollo:" -ForegroundColor Gray
Write-Host "  cd $frontendPath" -ForegroundColor Gray
Write-Host "  npm run dev" -ForegroundColor Gray

