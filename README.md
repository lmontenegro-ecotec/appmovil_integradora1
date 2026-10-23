# Catálogo Electrónico – Actividad Integradora 1

App Flutter de catálogo de productos electrónicos (MVP) para la asignatura Desarrollo de Aplicaciones Móviles – Universidad Ecotec.

## Funcionalidades
- Pantalla principal con lista de productos (ListView.builder + Card + ListTile).
- Pantalla de detalle que recibe el producto seleccionado como parámetro.
- Marcar producto como favorito (StatefulWidget + setState).
- Navegación ida y vuelta con Navigator.push / Navigator.pop.

## Estructura
lib/
├── main.dart
├── models/producto.dart
├── widgets/producto_card.dart
└── screens/
    ├── home_screen.dart
    └── detalle_screen.dart

## Ejecución
flutter pub get
flutter run

## Autor
Lenin Montenegro