# TiendaTec — Catálogo de tecnología (Flutter)

> **Actividad Integradora 3** – Consumo de una API REST pública y gestión de estados
> Desarrollo de Aplicaciones Móviles · Universidad Ecotec · Lenin Montenegro Santana

TiendaTec es la evolución de la app de catálogo de productos electrónicos de las **Actividades Integradoras 1 y 2** (`appmovil_integradora1`). En esta tercera fase el catálogo se obtiene **en tiempo real desde la API pública DummyJSON** mediante peticiones HTTP, con manejo explícito de los estados **Cargando**, **Éxito** y **Error**, cuadrícula de productos y actualización manual (*pull-to-refresh*).

Versiones anteriores: tag [`v1.0-integradora1`](../../tree/v1.0-integradora1) (Integradora 1) y [`v2.0.0`](../../tree/v2.0.0) (Integradora 2: rebranding y servicios nativos).

---

## API pública consumida

| Elemento | Detalle |
|---|---|
| API | [DummyJSON – Products](https://dummyjson.com/docs/products) (gratuita, **sin token ni autenticación**) |
| Endpoint | `GET https://dummyjson.com/products/category/{categoria}?select=title,description,price,thumbnail,category,rating` |
| Categorías | `smartphones`, `laptops`, `tablets`, `mobile-accessories` (se piden en paralelo con `Future.wait`) |
| Respuesta | Objeto JSON con la lista `products` (`id`, `title`, `description`, `price`, `rating`, `category`, `thumbnail`) |
| Mapeo | `Producto.fromApiJson` con valores por defecto (`??`) si algún campo llega `null` |

Ejemplo para probar en el navegador: <https://dummyjson.com/products/category/smartphones?select=title,price,thumbnail>

---

## Funcionalidades

| Módulo | Descripción |
|---|---|
| **Rebranding** | Nuevo nombre comercial *TiendaTec*, identificador `com.lmontenegro.tiendatec`, ícono propio (Android adaptativo, iOS y web), *splash screen* nativa y paleta unificada en `AppTheme`. |
| **Catálogo (API)** | Productos de tecnología consumidos desde la API pública DummyJSON, mostrados en una cuadrícula con imagen, precio y calificación; detalle con categoría y favorito. |
| **Estados de la petición** | `EstadoCatalogo { cargando, exito, error }` en `CatalogoProvider`: indicador de carga, catálogo, o pantalla de error con *Reintentar* y *Ver catálogo guardado*. *Pull-to-refresh* en todos los estados. |
| **Conectividad** | Detección de red en tiempo real con `Stream` (`connectivity_plus`) + verificación de internet real, banner *offline* animado y recarga automática al reconectar. |
| **Caché** | El último catálogo descargado se guarda en el dispositivo (`shared_preferences`) y puede consultarse desde la pantalla de error cuando no hay conexión. |
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
  ├── repository/  → catálogo (API + caché) y foto de perfil
  └── services/    → API DummyJSON (http) · conectividad · cámara/permisos · notificaciones
```

| Carpeta | Contenido |
|---|---|
| [`lib/main.dart`](lib/main.dart) | Punto de entrada: inicializa servicios, `MultiProvider`, rutas y tema. |
| [`lib/routes/`](lib/routes) | `AppRoutes`: rutas con nombre (`/`, `/detalle`, `/perfil`). |
| [`lib/theme/`](lib/theme) | `AppTheme`: colores de marca y `ThemeData`. |
| [`lib/models/`](lib/models) | `Producto` con `fromApiJson`, `fromJson` y `toJson`. |
| [`lib/repository/`](lib/repository) | `ProductoRepository` (API + caché) y `PerfilRepository`. |
| [`lib/providers/`](lib/providers) | `CatalogoProvider` y `ConectividadProvider`. |
| [`lib/services/`](lib/services) | `TiendaApiService` (HTTP GET, timeout, `ApiException`), `ConectividadService`, `CamaraService`, `NotificacionesService`. |
| [`lib/screens/`](lib/screens) | `HomeScreen`, `DetalleScreen`, `PerfilScreen` + barril `screens.dart`. |
| [`lib/widgets/`](lib/widgets) | `ProductoCard`, `ProductoImagen`, `CargandoView`, `ErrorView`, `OfflineBanner` + barril `widgets.dart`. |
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

### Cómo probar la API y los estados

1. **Éxito:** al abrir la app se muestra *"Cargando productos..."* y luego la cuadrícula con *"Datos en vivo desde la API DummyJSON"*.
2. **Actualización manual:** deslizar hacia abajo (*pull-to-refresh*) o tocar ↻ en la barra superior.
3. **Error:** activar el modo avión y tocar ↻ → pantalla de error con *Reintentar* y *Ver catálogo guardado*.

### Cómo probar los servicios nativos

1. **Modo offline:** activar el modo avión → aparece el banner *"Sin conexión a internet"* y una notificación. Al desactivarlo se recarga desde la API.
2. **Permisos de cámara:** ícono de perfil (AppBar) → *Tomar foto con la cámara* → aceptar o rechazar el permiso.
3. **Notificaciones:** aceptar el permiso al abrir la app y marcar un producto como favorito.

---

## Dependencias principales

| Paquete | Uso |
|---|---|
| `provider` | Gestión de estado |
| `http` | Peticiones GET a la API DummyJSON |
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

- `main`: versión estable.
- `develop`: integración.
- `feature/*`: una rama por módulo, integrada mediante *Pull Request*:

| PR | Rama | Contenido |
|---|---|---|
| #1 | `feature/rebranding` | Nombre, package id, ícono, splash y tema |
| #2 | `feature/arquitectura` | Rutas con nombre, repositorio JSON y Provider |
| #3 | `feature/conectividad` | Stream de red, banner offline y caché |
| #4 | `feature/camara-permisos` | Permisos en tiempo de ejecución y foto de perfil |
| #5 | `feature/notificaciones` | Notificaciones locales ante eventos clave |
| #6 | `develop → main` | Release `v2.0.0` (Integradora 2) |
| #7 | `feature/api-integration` | Consumo de la API DummyJSON y estados Cargando / Éxito / Error |
| #8 | `develop → main` | Release `v3.0.0` (Integradora 3) |

---

## Uso de Inteligencia Artificial

Se utilizó **Claude (Anthropic)** como asistente para seleccionar la API, guiar el desarrollo y diagnosticar errores de compilación y del emulador, y generar las ilustraciones de productos y del logotipo. El código fue integrado, probado en el emulador y versionado por el autor.

## Autor

**Lenin Montenegro Santana** — Carrera de Sistemas Inteligentes, Universidad Ecotec · [@lmontenegro-ecotec](https://github.com/lmontenegro-ecotec)
