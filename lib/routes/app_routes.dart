import 'package:flutter/material.dart';
import 'package:appmovil_integradora1/models/producto.dart';
import 'package:appmovil_integradora1/screens/screens.dart';

/// Clase que centraliza todas las rutas de TiendaTec
/// (mismo esquema visto en clase con AppRoutes).
class AppRoutes {
  // Nombres de las rutas
  static const String inicio = '/';
  static const String detalle = '/detalle';

  // Mapa de rutas: relaciona cada nombre con la función que construye la pantalla
  static final Map<String, WidgetBuilder> rutas = {
    inicio: (context) => const HomeScreen(),
    // El producto llega como argumento desde Navigator.pushNamed
    detalle: (context) => DetalleScreen(
          producto: ModalRoute.of(context)!.settings.arguments as Producto,
        ),
  };
}
