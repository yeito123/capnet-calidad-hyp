# Manual Deployment Guide - Windows + IIS

## 📋 Prerequisites

### 1. Install Required Software

- **Python 3.10+** (Download from python.org)
- **Node.js 18+** (Download from nodejs.org)
- **IIS** (Internet Information Services)
- **NSSM** (Non-Sucking Service Manager) for running Python backend as a service
- **SQL Server** (should already be configured)

### 2. Enable IIS Features

Open PowerShell as Administrator and run:

```powershell
# Enable IIS
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole

# Enable necessary IIS features
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DirectoryBrowsing
```

---

## 🔧 PART 1: Backend Deployment (FastAPI)

### Step 1: Prepare Python Environment

```powershell
# Navigate to backend folder
cd D:\capnet\capnet_calidad_hyp\backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 2: Configure Environment Variables

Create a `.env` file in the backend folder:

```powershell
# Create .env file
cd D:\capnet\capnet_calidad_hyp\backend
notepad .env
```

Add the following content (adjust values as needed):

```env
# Database Configuration
DB_SERVER=your_sql_server_host
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_database_name
DB_DRIVER=ODBC Driver 17 for SQL Server

# Application Configuration
CALIDAD_FASE_ID=1
PREVIUS_FASE_ID=0

# CORS (adjust for production)
CORS_ORIGINS=["http://localhost:3000", "http://your-domain.com"]

# Project Info
PROJECT_NAME=Tablero HYP Calidad
VERSION=1.0.0
```

### Step 3: Test Backend Locally

```powershell
# Make sure venv is activated
cd D:\capnet\capnet_calidad_hyp\backend
.\venv\Scripts\Activate.ps1

# Test run
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Visit `http://localhost:8000` to see if it works. You should see a JSON response. Try `http://localhost:8000/docs` for the API documentation.

Press `Ctrl+C` to stop.

### Step 4: Install NSSM (Service Manager)

```powershell
# Download NSSM from https://nssm.cc/download
# Extract to C:\nssm\

# Or download via PowerShell
$nssmUrl = "https://nssm.cc/release/nssm-2.24.zip"
$downloadPath = "$env:TEMP\nssm.zip"
Invoke-WebRequest -Uri $nssmUrl -OutFile $downloadPath

# Extract
Expand-Archive -Path $downloadPath -DestinationPath "C:\nssm" -Force
```

### Step 5: Create Windows Service for Backend

```powershell
# Create the service
C:\nssm\nssm-2.24\win64\nssm.exe install CalidadHYPAPI

# This will open a GUI. Configure as follows:
# Path: D:\capnet\capnet_calidad_hyp\backend\venv\Scripts\python.exe
# Startup directory: D:\capnet\capnet_calidad_hyp\backend
# Arguments: -m uvicorn app.main:app --host 0.0.0.0 --port 8000

# Or configure via command line:
$pythonPath = "D:\capnet\capnet_calidad_hyp\backend\venv\Scripts\python.exe"
$backendPath = "D:\capnet\capnet_calidad_hyp\backend"
$nssmPath = "C:\nssm\nssm-2.24\win64\nssm.exe"

& $nssmPath set CalidadHYPAPI Application $pythonPath
& $nssmPath set CalidadHYPAPI AppDirectory $backendPath
& $nssmPath set CalidadHYPAPI AppParameters "-m uvicorn app.main:app --host 0.0.0.0 --port 8000"
& $nssmPath set CalidadHYPAPI DisplayName "Calidad HYP API Service"
& $nssmPath set CalidadHYPAPI Description "FastAPI backend service for Calidad HYP"
& $nssmPath set CalidadHYPAPI Start SERVICE_AUTO_START

# Set environment file
& $nssmPath set CalidadHYPAPI AppEnvironmentExtra ":DOTENV_PATH=D:\capnet\capnet_calidad_hyp\backend\.env"

# Start the service
Start-Service CalidadHYPAPI

# Check status
Get-Service CalidadHYPAPI
```

### Step 6: Configure Windows Firewall

```powershell
# Allow port 8000 for the backend API
New-NetFirewallRule -DisplayName "Calidad HYP API" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow
```

---

## 🌐 PART 2: Frontend Deployment (Next.js)

### Step 1: Configure Frontend Environment

```powershell
cd D:\capnet\capnet_calidad_hyp\frontend\calidad-hyp

# Create .env.local file
notepad .env.local
```

Add the following:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
# Or use your server's IP/domain:
# NEXT_PUBLIC_API_URL=http://your-server-ip:8000/api
```

### Step 2: Build Frontend for Production

```powershell
cd D:\capnet\capnet_calidad_hyp\frontend\calidad-hyp

# Install dependencies
npm install

# Build for production
npm run build

# This creates an optimized production build in the .next folder
```

### Step 3: Option A - Deploy as Static Export to IIS

If you want to use static export (no server-side rendering):

```powershell
# Add to next.config.mjs
# output: 'export'
```

Then rebuild and copy to IIS:

```powershell
npm run build
# Copy the 'out' folder to IIS

xcopy /E /I /Y "D:\capnet\capnet_calidad_hyp\frontend\calidad-hyp\out\*" "C:\inetpub\wwwroot\calidad-hyp\"
```

### Step 4: Option B - Run Next.js as Node Service (Recommended)

Create a Windows service for Next.js:

```powershell
# Install PM2 globally (process manager for Node.js)
npm install -g pm2
npm install -g pm2-windows-startup

# Configure PM2 to start on boot
pm2-startup install

# Start Next.js with PM2
cd D:\capnet\capnet_calidad_hyp\frontend\calidad-hyp
pm2 start npm --name "calidad-hyp-frontend" -- start

# Save the PM2 process list
pm2 save

# Check status
pm2 status
pm2 logs calidad-hyp-frontend
```

Or use NSSM for Next.js:

```powershell
$nodePath = "C:\Program Files\nodejs\node.exe"  # Adjust path
$frontendPath = "D:\capnet\capnet_calidad_hyp\frontend\calidad-hyp"
$nssmPath = "C:\nssm\nssm-2.24\win64\nssm.exe"

& $nssmPath install CalidadHYPFrontend $nodePath
& $nssmPath set CalidadHYPFrontend AppDirectory $frontendPath
& $nssmPath set CalidadHYPFrontend AppParameters "node_modules\next\dist\bin\next start -p 3000"
& $nssmPath set CalidadHYPFrontend DisplayName "Calidad HYP Frontend"
& $nssmPath set CalidadHYPFrontend Description "Next.js frontend for Calidad HYP"
& $nssmPath set CalidadHYPFrontend Start SERVICE_AUTO_START

Start-Service CalidadHYPFrontend
```

---

## 🔄 PART 3: IIS Configuration (Reverse Proxy)

### Step 1: Install URL Rewrite Module

Download and install from: https://www.iis.net/downloads/microsoft/url-rewrite

### Step 2: Install Application Request Routing (ARR)

Download and install from: https://www.iis.net/downloads/microsoft/application-request-routing

After installing, enable proxy in ARR:

1. Open IIS Manager
2. Click on server name in left panel
3. Double-click "Application Request Routing Cache"
4. Click "Server Proxy Settings" in right panel
5. Check "Enable proxy"
6. Click Apply

### Step 3: Create IIS Site

```powershell
# Import IIS module
Import-Module WebAdministration

# Create application pool
New-WebAppPool -Name "CalidadHYPPool"
Set-ItemProperty IIS:\AppPools\CalidadHYPPool -Name managedRuntimeVersion -Value ""

# Create site directory if it doesn't exist
$sitePath = "C:\inetpub\wwwroot\calidad-hyp"
if (!(Test-Path $sitePath)) {
    New-Item -ItemType Directory -Path $sitePath
}

# Create IIS website
New-Website -Name "CalidadHYP" -Port 80 -PhysicalPath $sitePath -ApplicationPool "CalidadHYPPool"

# Start the site
Start-Website -Name "CalidadHYP"
```

### Step 4: Configure URL Rewrite Rules

Create a `web.config` file in `C:\inetpub\wwwroot\calidad-hyp\web.config`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <!-- Reverse proxy for backend API -->
                <rule name="ReverseProxyAPI" stopProcessing="true">
                    <match url="^api/(.*)" />
                    <action type="Rewrite" url="http://localhost:8000/api/{R:1}" />
                    <serverVariables>
                        <set name="HTTP_X_ORIGINAL_HOST" value="{HTTP_HOST}" />
                    </serverVariables>
                </rule>

                <!-- Reverse proxy for frontend -->
                <rule name="ReverseProxyFrontend" stopProcessing="true">
                    <match url="(.*)" />
                    <action type="Rewrite" url="http://localhost:3000/{R:1}" />
                    <serverVariables>
                        <set name="HTTP_X_ORIGINAL_HOST" value="{HTTP_HOST}" />
                    </serverVariables>
                </rule>
            </rules>

            <!-- Allow query string pass-through -->
            <outboundRules>
                <rule name="AddResponseHeaders">
                    <match serverVariable="RESPONSE_Server" pattern=".+" />
                    <action type="Rewrite" value="" />
                </rule>
            </outboundRules>
        </rewrite>

        <httpProtocol>
            <customHeaders>
                <add name="X-Content-Type-Options" value="nosniff" />
                <add name="X-Frame-Options" value="SAMEORIGIN" />
                <add name="X-XSS-Protection" value="1; mode=block" />
            </customHeaders>
        </httpProtocol>

        <!-- Allow all HTTP methods -->
        <security>
            <requestFiltering>
                <verbs allowUnlisted="true">
                    <add verb="GET" allowed="true" />
                    <add verb="POST" allowed="true" />
                    <add verb="PUT" allowed="true" />
                    <add verb="DELETE" allowed="true" />
                    <add verb="PATCH" allowed="true" />
                </verbs>
            </requestFiltering>
        </security>
    </system.webServer>
</configuration>
```

Or create it via PowerShell:

```powershell
$webConfigContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <rule name="ReverseProxyAPI" stopProcessing="true">
                    <match url="^api/(.*)" />
                    <action type="Rewrite" url="http://localhost:8000/api/{R:1}" />
                </rule>
                <rule name="ReverseProxyFrontend" stopProcessing="true">
                    <match url="(.*)" />
                    <action type="Rewrite" url="http://localhost:3000/{R:1}" />
                </rule>
            </rules>
        </rewrite>
    </system.webServer>
</configuration>
"@

$webConfigContent | Out-File -FilePath "C:\inetpub\wwwroot\calidad-hyp\web.config" -Encoding UTF8
```

### Step 5: Configure Windows Firewall for HTTP

```powershell
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
```

---

## 🧪 Testing the Deployment

### 1. Test Backend Service

```powershell
# Check service status
Get-Service CalidadHYPAPI

# Test direct API access
curl http://localhost:8000

# Test API endpoint
curl http://localhost:8000/api/calidad
```

### 2. Test Frontend Service

```powershell
# Check if using PM2
pm2 status

# Or check Windows service
Get-Service CalidadHYPFrontend

# Test direct frontend access
# Open browser: http://localhost:3000
```

### 3. Test IIS Reverse Proxy

Open a browser and navigate to:

- `http://localhost` - Should show the frontend
- `http://localhost/api` - Should proxy to backend API
- `http://your-server-ip` - Should work from other machines

---

## 🐛 Troubleshooting

### Backend Issues

```powershell
# View service logs
Get-EventLog -LogName Application -Source CalidadHYPAPI -Newest 20

# Manually test the service
cd D:\capnet\capnet_calidad_hyp\backend
.\venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000

# Check if port is in use
netstat -ano | findstr :8000

# Restart service
Restart-Service CalidadHYPAPI
```

### Frontend Issues

```powershell
# Check PM2 logs
pm2 logs calidad-hyp-frontend

# Or check Windows service
Get-EventLog -LogName Application -Source CalidadHYPFrontend -Newest 20

# Check if port is in use
netstat -ano | findstr :3000

# Rebuild and restart
cd D:\capnet\capnet_calidad_hyp\frontend\calidad-hyp
npm run build
pm2 restart calidad-hyp-frontend
```

### IIS Issues

```powershell
# Check IIS website status
Get-Website -Name "CalidadHYP"

# Restart IIS site
Stop-Website -Name "CalidadHYP"
Start-Website -Name "CalidadHYP"

# Check IIS logs
Get-Content C:\inetpub\logs\LogFiles\W3SVC1\*.log | Select-Object -Last 20

# Test URL Rewrite
# Install Failed Request Tracing in IIS to debug rewrite rules
```

### Database Connection Issues

```powershell
# Test ODBC connection
cd D:\capnet\capnet_calidad_hyp\backend
.\venv\Scripts\Activate.ps1
python -c "import pyodbc; print(pyodbc.drivers())"

# Check if SQL Server driver is installed
# Download from: https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server
```

---

## 📝 Maintenance Commands

### Update Application

```powershell
# Pull latest code
cd D:\capnet\capnet_calidad_hyp
git pull

# Update backend
cd backend
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
Restart-Service CalidadHYPAPI

# Update frontend
cd ..\frontend\calidad-hyp
npm install
npm run build
pm2 restart calidad-hyp-frontend
```

### View Logs

```powershell
# Backend logs
Get-EventLog -LogName Application -Source CalidadHYPAPI -Newest 50

# Frontend logs (PM2)
pm2 logs calidad-hyp-frontend

# IIS logs
Get-Content C:\inetpub\logs\LogFiles\W3SVC1\*.log -Tail 50
```

### Stop/Start Services

```powershell
# Stop all
Stop-Service CalidadHYPAPI
pm2 stop calidad-hyp-frontend
Stop-Website -Name "CalidadHYP"

# Start all
Start-Service CalidadHYPAPI
pm2 start calidad-hyp-frontend
Start-Website -Name "CalidadHYP"
```

---

## 🎉 You're Done!

Your application should now be running:

- Frontend: `http://your-server/`
- Backend API: `http://your-server/api/`
- API Docs: `http://your-server/api/docs` (if using direct backend access)

For production, consider:

1. Setting up HTTPS with SSL certificates
2. Configuring a proper domain name
3. Setting up automated backups
4. Implementing monitoring and alerting
5. Hardening security settings

---

## 📞 Quick Reference

```powershell
# Service Management
Get-Service CalidadHYPAPI                    # Check backend status
Get-Service CalidadHYPFrontend              # Check frontend status (if using NSSM)
pm2 status                                   # Check PM2 processes

# Restart Everything
Restart-Service CalidadHYPAPI
pm2 restart calidad-hyp-frontend
iisreset

# Check Ports
netstat -ano | findstr :8000                # Backend port
netstat -ano | findstr :3000                # Frontend port
netstat -ano | findstr :80                  # IIS port

# Logs
pm2 logs calidad-hyp-frontend --lines 100
Get-EventLog -LogName Application -Newest 50
```
