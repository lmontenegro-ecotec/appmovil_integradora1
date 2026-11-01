# TiendaTec — Catálogo de tecnología (Flutter)

> **Actividad Integradora 2** – Reingeniería, Gestión de Servicios Nativos y Auditoría de Código en Repositorio Público
> Desarrollo de Aplicaciones Móviles · Universidad Ecotec · Lenin Montenegro Santana

TiendaTec es la evolución de la app de catálogo de productos electrónicos de la **Actividad Integradora 1** (`appmovil_integradora1`). En esta segunda fase se aplicó un **rebranding visual completo**, una **arquitectura por capas** y **tres servicios nativos**: conectividad en tiempo real, cámara/galería con permisos y notificaciones locales.

El estado entregado en la Integradora 1 se conserva en el tag [`v1.0-integradora1`](../../tree/v1.0-integradora1).

---

## Funcionalidades

| Módulo | Descripción |
|---|---|
| **Rebranding** | Nuevo nombre comercial *TiendaTec*, identificador `com.lmontenegro.tiendatec`, ícono propio (Android adaptativo, iOS y web), *splash screen* nativa y paleta unificada en `AppTheme`. |
| **Catálogo** | Lista de productos descargada desde un JSON remoto ([`data/productos.json`](data/productos.json)), detalle con favorito y navegación con rutas con nombre. |
| **Conectividad** | Detección de red en tiempo real con `Stream` (`connectivity_plus`) + verificación de internet real, banner *offline* animado y recarga automática al reconectar. |
| **Caché** | El último catálogo descargado se guarda en el dispositivo (`shared_preferences`) y se muestra sin conexión. |
| **Cámara y galería** | Foto de perfil con solicitud de permisos en tiempo de ejecución (concedido / denegado / bloqueado con acceso a Ajustes), compresión (70 %, máx. 800 px) y persistencia. |
| **Notificaciones locales** | Canal nativo Android *"Alertas TiendaTec"* y ajustes iOS; alertas al perder/recuperar la conexión, al marcar un favorito y al cambiar la foto de perfil. |

---

## Arquitectura

La interfaz no accede directamente a la red, la cámara ni las notificaciones: esa lógica está desacoplada en **servicios** y **repositorios**, y el estado se gestiona con **Provider**.

```
UI (screens / widgets)
        │  context.watch / Navigator.pushNamed
        ▼
Estado (providers)  ── ChangeNotifier
        │
        ▼
Datos y servicios nativos
  ├── repository/  → catálogo (HTTP + caché) y foto de perfil
  └── services/    → conectividad · cámara/permisos · notificaciones
```

| Carpeta | Contenido |
|---|---|
| [`lib/main.dart`](lib/main.dart) | Punto de entrada: inicializa servicios, `MultiProvider`, rutas y tema. |
| [`lib/routes/`](lib/routes) | `AppRoutes`: rutas con nombre (`/`, `/detalle`, `/perfil`). |
| [`lib/theme/`](lib/theme) | `AppTheme`: colores de marca y `ThemeData`. |
| [`lib/models/`](lib/models) | `Producto` con `fromJson` / `toJson`. |
| [`lib/repository/`](lib/repository) | `ProductoRepository` (HTTP, timeout, caché, respaldo local) y `PerfilRepository`. |
| [`lib/providers/`](lib/providers) | `CatalogoProvider` y `ConectividadProvider`. |
| [`lib/services/`](lib/services) | `ConectividadService`, `CamaraService`, `NotificacionesService`. |
| [`lib/screens/`](lib/screens) | `HomeScreen`, `DetalleScreen`, `PerfilScreen` + barril `screens.dart`. |
| [`lib/widgets/`](lib/widgets) | `ProductoCard`, `OfflineBanner` + barril `widgets.dart`. |
| [`assets/`](assets) | Imágenes de productos y recursos de marca (ícono y splash). |
| [`data/`](data) | Catálogo remoto en JSON. |

---

## Instalación y ejecución

**Requisitos:** Flutter 3.47 (Dart 3.13), Android SDK 36/37, emulador o dispositivo Android (Android 13+ recomendado para probar permisos de notificaciones).

```bash
git clone https://github.com/lmontenegro-ecotec/appmovil_integradora1.git
cd appmovil_integradora1
flutter pub get
flutter run
```

Regenerar ícono y splash (solo si se cambian los recursos de `assets/branding`):

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Cómo probar los servicios nativos

1. **Modo offline:** activar el modo avión → aparece el banner *"Sin conexión a internet"*, una notificación y el catálogo guardado. Al desactivarlo se recarga desde internet.
2. **Permisos de cámara:** ícono de perfil (AppBar) → *Tomar foto con la cámara* → aceptar o rechazar el permiso.
3. **Notificaciones:** aceptar el permiso al abrir la app y marcar un producto como favorito.

---

## Dependencias principales

| Paquete | Uso |
|---|---|
| `provider` | Gestión de estado |
| `http` | Descarga del catálogo JSON |
| `connectivity_plus` | Stream de cambios de red |
| `shared_preferences` | Caché del catálogo y ruta de la foto |
| `image_picker` | Cámara / galería con compresión |
| `permission_handler` | Permisos en tiempo de ejecución |
| `path_provider` | Carpeta privada para la foto de perfil |
| `flutter_local_notifications` | Notificaciones locales con canales nativos |
| `flutter_launcher_icons`, `flutter_native_splash` | Ícono y splash (desarrollo) |

**Permisos declarados:** `INTERNET`, `CAMERA`, `READ_MEDIA_IMAGES`, `POST_NOTIFICATIONS` (Android) · `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` (iOS).

---

## Control de versiones

- `main`: versión estable con el rebranding.
- `develop`: integración.
- `feature/*`: una rama por módulo, integrada mediante *Pull Request*:

| PR | Rama | Contenido |
|---|---|---|
| #1 | `feature/rebranding` | Nombre, package id, ícono, splash y tema |
| #2 | `feature/arquitectura` | Rutas con nombre, repositorio JSON y Provider |
| #3 | `feature/conectividad` | Stream de red, banner offline y caché |
| #4 | `feature/camara-permisos` | Permisos en tiempo de ejecución y foto de perfil |
| #5 | `feature/notificaciones` | Notificaciones locales ante eventos clave |

---

## Uso de Inteligencia Artificial

Se utilizó **Claude (Anthropic)** como asistente para guiar y diagnosticar errores de compilación y del emulador, y generar las ilustraciones de productos y del logotipo. El código fue integrado, probado en el emulador y versionado por el autor.

## Autor

**Lenin Montenegro Santana** — Carrera de Sistemas Inteligentes, Universidad Ecotec · [@lmontenegro-ecotec](https://github.com/lmontenegro-ecotec)
