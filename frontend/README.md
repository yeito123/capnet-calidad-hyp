# Frontend - Tablero HYP Calidad

Aplicación web moderna desarrollada con Next.js 16 para el sistema de gestión de calidad de vehículos.

## 🛠️ Tecnologías

- **Framework**: Next.js 16.0.4 con App Router
- **React**: 19.2.0
- **TypeScript**: 5.x
- **Estilos**: Tailwind CSS 4.x
- **State Management**: Zustand 5.0.8
- **Data Fetching**: TanStack Query (React Query) 5.90.10
- **HTTP Client**: Axios 1.13.2
- **Formularios**: React Hook Form 7.66.1 + Zod 4.1.13
- **UI Components**: Heroicons 2.2.0
- **Alertas**: SweetAlert2 11.26.3

## 📁 Estructura del Proyecto

```
frontend/calidad-hyp/
├── public/                      # Archivos estáticos
├── src/
│   ├── app/                     # App Router de Next.js
│   │   ├── globals.css         # Estilos globales
│   │   ├── layout.tsx          # Layout principal
│   │   └── page.tsx            # Página principal
│   ├── core/                   # Funcionalidades core
│   │   ├── app.store.ts        # Store global de la app
│   │   ├── alerts/             # Sistema de alertas
│   │   │   ├── alert.service.ts
│   │   │   └── useAlerts.ts
│   │   ├── config/             # Configuración
│   │   │   └── env.ts          # Variables de entorno
│   │   ├── http/               # Cliente HTTP
│   │   │   ├── auth-client.ts  # Cliente con auth
│   │   │   └── client.ts       # Cliente base
│   │   └── utils/              # Utilidades
│   │       └── format.ts       # Formateo de datos
│   └── modules/                # Módulos de negocio
│       └── calidad/            # Módulo de calidad
│           ├── calidad.api.ts       # API calls
│           ├── calidad.store.ts     # Zustand store
│           ├── calidad.types.ts     # TypeScript types
│           ├── useCalidad.ts        # Custom hook
│           ├── components/          # Componentes
│           │   ├── CalidadCard.tsx
│           │   ├── CalidadComments.tsx
│           │   ├── CalidadList.tsx
│           │   ├── Modal.tsx
│           │   └── NavBar.tsx
│           └── pages/               # Páginas
│               └── Home.tsx
├── eslint.config.mjs
├── next.config.mjs
├── package.json
├── postcss.config.mjs
├── tailwind.config.js
├── tsconfig.json
└── README.md
```

## 🚀 Instalación

### Prerrequisitos

- Node.js 18.x o superior
- npm, yarn, pnpm o bun

### Pasos de instalación

1. **Navegar a la carpeta del frontend**

   ```bash
   cd frontend/calidad-hyp
   ```

2. **Instalar dependencias**

   ```bash
   npm install
   # o
   yarn install
   # o
   pnpm install
   ```

3. **Configurar variables de entorno**

   Crear un archivo `.env.local` en `frontend/calidad-hyp/` con:

   ```env
   # URL del backend
   NEXT_PUBLIC_API_URL=http://localhost:8000/api

   # Configuración regional (opcional)
   NEXT_PUBLIC_DEFAULT_LOCALE=es-CO
   NEXT_PUBLIC_DEFAULT_CURRENCY=COP
   ```

4. **Ejecutar en modo desarrollo**

   ```bash
   npm run dev
   # o
   yarn dev
   # o
   pnpm dev
   ```

   La aplicación estará disponible en: `http://localhost:3000/calidad-hyp/`

## 📦 Scripts Disponibles

```bash
# Desarrollo
npm run dev          # Inicia el servidor de desarrollo

# Producción
npm run build        # Genera build de producción
npm run start        # Inicia el servidor de producción

# Calidad de código
npm run lint         # Ejecuta ESLint
```

## 🏗️ Arquitectura

### Patrón de diseño

El proyecto sigue una arquitectura modular basada en:

1. **Module Pattern**: Cada funcionalidad (calidad) es un módulo independiente
2. **Custom Hooks**: Encapsulación de lógica reutilizable
3. **State Management**: Zustand para estado global, React Query para estado del servidor
4. **Separation of Concerns**: API, Store, Types y Components separados

### Estructura de un módulo

```
modules/calidad/
├── calidad.api.ts        # Llamadas HTTP al backend
├── calidad.store.ts      # Estado global con Zustand
├── calidad.types.ts      # Tipos TypeScript
├── useCalidad.ts         # Custom hook principal
├── components/           # Componentes del módulo
└── pages/               # Páginas del módulo
```

### Flujo de datos

```
Componente → Hook → Store → API → Backend
                ↓
            React Query
                ↓
            Cache/Estado
```

## 🎨 Estilos y Diseño

### Tailwind CSS

El proyecto usa Tailwind CSS v4 con configuración personalizada:

- **Dark Mode**: Soportado con clase `dark`
- **Variables CSS**: Colores de marca personalizables
- **Plugins**: `@tailwindcss/forms` para mejores formularios

### Variables de marca

Definidas en `globals.css`:

```css
--brand-primary
--brand-secondary
--brand-accent
--brand-background
--brand-text
```

## 🔌 Integración con Backend

### Cliente HTTP

El proyecto incluye dos clientes HTTP configurados:

1. **client.ts**: Cliente base con Axios
2. **auth-client.ts**: Cliente con manejo de autenticación

### Configuración de API

```typescript
// src/core/config/env.ts
export const ENV = {
  API_URL: process.env.NEXT_PUBLIC_API_URL ?? "",
  DEFAULT_LOCALE: process.env.NEXT_PUBLIC_DEFAULT_LOCALE ?? "es-CO",
  DEFAULT_CURRENCY: process.env.NEXT_PUBLIC_DEFAULT_CURRENCY ?? "COP",
};
```

## 📱 Características Principales

### Módulo de Calidad

- ✅ Listado de vehículos en fase de calidad
- ✅ Búsqueda y filtrado de vehículos
- ✅ Visualización de detalles del vehículo
- ✅ Sistema de comentarios
- ✅ Iniciar/Finalizar proceso de calidad
- ✅ Información de fases previas

### Sistema de Alertas

Implementado con SweetAlert2 para:

- Confirmaciones de acciones
- Mensajes de éxito/error
- Alertas informativas

### Gestión de Estado

- **Zustand**: Estado global de la aplicación
- **React Query**: Cache y sincronización de datos del servidor
- **React Hook Form**: Estado de formularios con validación Zod

## 🔧 Desarrollo

### Agregar un nuevo módulo

1. Crear carpeta en `src/modules/nombre_modulo/`
2. Crear archivos base:
   ```
   nombre_modulo.api.ts
   nombre_modulo.store.ts
   nombre_modulo.types.ts
   useNombreModulo.ts
   components/
   pages/
   ```
3. Implementar la lógica siguiendo el patrón del módulo calidad

### Buenas prácticas

- ✅ Usar TypeScript para todo
- ✅ Componentes funcionales con hooks
- ✅ Props tipadas con interfaces
- ✅ Validación de formularios con Zod
- ✅ Manejo de errores apropiado
- ✅ Loading states y feedback visual
- ✅ Responsive design con Tailwind
- ✅ Accesibilidad (a11y)

### Convenciones de código

```typescript
// Nombres de componentes: PascalCase
export function CalidadCard() {}

// Nombres de hooks: camelCase con 'use' prefix
export function useCalidad() {}

// Nombres de tipos: PascalCase
export interface CalidadResponse {}

// Nombres de archivos: kebab-case
// calidad-card.tsx, use-calidad.ts
```

## 🌐 Configuración de Next.js

### Base Path

La aplicación está configurada con:

```javascript
basePath: "/calidad-hyp";
assetPrefix: "/calidad-hyp";
trailingSlash: true;
```

Esto permite despliegue en subdirectorios.

### React Compiler

Habilitado para optimizaciones automáticas:

```javascript
reactCompiler: true;
```

## 🚀 Despliegue

### Build de Producción

```bash
# Generar build optimizado
npm run build

# Iniciar servidor de producción
npm run start
```

### Variables de entorno en producción

Asegúrate de configurar:

```env
NEXT_PUBLIC_API_URL=https://tu-api.com/api
```

### Opciones de despliegue

- **Vercel**: Despliegue automático desde Git
- **Docker**: Incluir Dockerfile para containerización
- **Servidor propio**: Nginx como proxy reverso
- **IIS**: Para Windows Server

### Ejemplo IIS

1. **Instalar URL Rewrite y Application Request Routing (ARR)**

   - Descargar e instalar [URL Rewrite Module](https://www.iis.net/downloads/microsoft/url-rewrite)
   - Descargar e instalar [Application Request Routing](https://www.iis.net/downloads/microsoft/application-request-routing)

2. **Habilitar Proxy en ARR**

   - Abrir IIS Manager
   - Seleccionar el servidor
   - Abrir "Application Request Routing Cache"
   - Ir a "Server Proxy Settings"
   - Marcar "Enable proxy"

3. **Configurar web.config**

   Crear o modificar `web.config` en la raíz del sitio:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <rule name="ReverseProxyInboundRule1" stopProcessing="true">
                    <match url="calidad-hyp/(.*)" />
                    <action type="Rewrite" url="http://localhost:3000/calidad-hyp/{R:1}" />
                    <serverVariables>
                        <set name="HTTP_X_ORIGINAL_HOST" value="{HTTP_HOST}" />
                    </serverVariables>
                </rule>
            </rules>
        </rewrite>
        <httpProtocol>
            <customHeaders>
                <add name="X-Powered-By" value="ASP.NET" />
            </customHeaders>
        </httpProtocol>
    </system.webServer>
</configuration>
```

4. **Configurar WebSocket (si es necesario)**

```xml
<system.webServer>
    <webSocket enabled="true" />
</system.webServer>
```

## 📝 Variables de Entorno

| Variable                       | Descripción              | Requerido | Default |
| ------------------------------ | ------------------------ | --------- | ------- |
| `NEXT_PUBLIC_API_URL`          | URL base del backend API | Sí        | -       |
| `NEXT_PUBLIC_DEFAULT_LOCALE`   | Locale por defecto       | No        | es-CO   |
| `NEXT_PUBLIC_DEFAULT_CURRENCY` | Moneda por defecto       | No        | COP     |

> **Nota**: Las variables con prefijo `NEXT_PUBLIC_` son expuestas al cliente.

## 🧪 Testing

```bash
# Configurar testing (pendiente)
npm install --save-dev @testing-library/react @testing-library/jest-dom jest

# Ejecutar tests
npm run test
```

## 📚 Recursos

- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Zustand](https://zustand-demo.pmnd.rs/)
- [TanStack Query](https://tanstack.com/query/latest)
- [React Hook Form](https://react-hook-form.com/)

## 🐛 Solución de Problemas

### Error: Cannot find module

```bash
# Limpiar caché y reinstalar
rm -rf node_modules package-lock.json
npm install
```

### Problemas con Tailwind CSS

```bash
# Verificar que PostCSS está configurado
npm run build
```

### Error de conexión con API

Verifica que:

1. El backend está ejecutándose
2. `NEXT_PUBLIC_API_URL` apunta a la URL correcta
3. CORS está configurado en el backend

## 📄 Licencia

Este proyecto es propiedad de CAPNET.

## 👥 Autores

Equipo de desarrollo CAPNET
