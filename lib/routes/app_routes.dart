import 'package:flutter/material.dart';
import 'package:appmovil_integradora1/models/producto.dart';
import 'package:appmovil_integradora1/screens/screens.dart';

/// Clase que centraliza todas las rutas de TiendaTec
/// (mismo esquema visto en clase con AppRoutes).
class AppRoutes {
  // Nombres de las rutas
  static const String inicio = '/';
  static const String detalle = '/detalle';
  static const String perfil = '/perfil';

  // Mapa de rutas: relaciona cada nombre con la función que construye la pantalla
  static final Map<String, WidgetBuilder> rutas = {
    inicio: (context) => const HomeScreen(),
    // El producto llega como argumento desde Navigator.pushNamed.
    // Si no llega (ej. hot reload), se vuelve al inicio en lugar de
    // romper la app con un error de null.
    detalle: (context) {
      final argumento = ModalRoute.of(context)?.settings.arguments;
      if (argumento is Producto) {
        return DetalleScreen(producto: argumento);
      }
      return const HomeScreen();
    },
    perfil: (context) => const PerfilScreen(),
  };
}
