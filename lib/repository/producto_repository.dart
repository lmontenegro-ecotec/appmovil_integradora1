import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appmovil_integradora1/models/producto.dart';

/// De dónde se obtuvieron los datos del catálogo.
enum OrigenDatos { red, cache, local }

/// Resultado de la carga del catálogo: la lista y su origen.
class ResultadoCatalogo {
  final List<Producto> productos;
  final OrigenDatos origen;
  final DateTime? guardadoEl; // fecha de la copia en caché (si aplica)
  const ResultadoCatalogo(this.productos, this.origen, [this.guardadoEl]);
}

/// Capa de datos: obtiene los productos de TiendaTec.
/// La interfaz no sabe si vienen de internet o de un respaldo local.
class ProductoRepository {
  /// Catálogo publicado en el propio repositorio de GitHub (rama develop).
  static const String urlCatalogo =
      'https://raw.githubusercontent.com/lmontenegro-ecotec/appmovil_integradora1/develop/data/productos.json';

  // Claves usadas para guardar la caché en el dispositivo
  static const String _claveCache = 'catalogo_cache';
  static const String _claveFecha = 'catalogo_cache_fecha';

  final http.Client _cliente;

  ProductoRepository({http.Client? cliente})
    : _cliente = cliente ?? http.Client();

  /// Descarga el catálogo. Si falla la red (sin conexión, timeout,
  /// error HTTP o JSON inválido) se usa la caché y, si no existe,
  /// el catálogo local de respaldo.
  Future<ResultadoCatalogo> obtenerProductos() async {
    try {
      final respuesta = await _cliente
          .get(Uri.parse(urlCatalogo))
          .timeout(const Duration(seconds: 8));

      if (respuesta.statusCode == 200) {
        final List<dynamic> datos = jsonDecode(
          utf8.decode(respuesta.bodyBytes),
        );
        final productos = datos
            .map((e) => Producto.fromJson(e as Map<String, dynamic>))
            .toList();
        debugPrint(
          'Catálogo cargado desde internet: ${productos.length} productos',
        );
        await _guardarEnCache(productos);
        return ResultadoCatalogo(productos, OrigenDatos.red);
      }
      debugPrint('Catálogo: respuesta HTTP ${respuesta.statusCode}');
    } on TimeoutException {
      debugPrint('Catálogo: tiempo de espera agotado');
    } catch (e) {
      debugPrint('Catálogo: error al descargar -> $e');
    }

    // 1) Sin red: se intenta usar la última copia guardada en el dispositivo
    final enCache = await _leerCache();
    if (enCache != null) return enCache;

    // 2) Si nunca se guardó nada, se usa el catálogo incluido en la app
    debugPrint('Catálogo: usando datos locales de respaldo');
    return const ResultadoCatalogo(productosLocales, OrigenDatos.local);
  }

  /// Guarda el catálogo descargado (persistencia local con SharedPreferences).
  Future<void> _guardarEnCache(List<Producto> productos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(productos.map((p) => p.toJson()).toList());
      await prefs.setString(_claveCache, json);
      await prefs.setString(_claveFecha, DateTime.now().toIso8601String());
      debugPrint('Caché: catálogo guardado (${productos.length} productos)');
    } catch (e) {
      debugPrint('Caché: no se pudo guardar -> $e');
    }
  }

  /// Lee la última copia guardada; devuelve null si no existe o está dañada.
  Future<ResultadoCatalogo?> _leerCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_claveCache);
      if (json == null) return null;
      final List<dynamic> datos = jsonDecode(json);
      final productos = datos
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList();
      final fecha = DateTime.tryParse(prefs.getString(_claveFecha) ?? '');
      debugPrint('Caché: usando catálogo guardado (${productos.length} productos)');
      return ResultadoCatalogo(productos, OrigenDatos.cache, fecha);
    } catch (e) {
      debugPrint('Caché: no se pudo leer -> $e');
      return null;
    }
  }

  /// Catálogo de respaldo incluido en la app (el de la Actividad Integradora 1).
  static const List<Producto> productosLocales = [
    Producto(
      id: 1,
      nombre: 'Laptop Pro 14',
      descripcion: 'Procesador de 12 núcleos, 16 GB RAM y SSD de 512 GB.',
      precio: 899.99,
      imagen: 'assets/productos/laptop.jpg',
    ),
    Producto(
      id: 2,
      nombre: 'Smartphone X',
      descripcion: 'Pantalla AMOLED de 6.5", cámara de 50 MP y 5G.',
      precio: 499.00,
      imagen: 'assets/productos/phone.jpg',
    ),
    Producto(
      id: 3,
      nombre: 'Audífonos BT',
      descripcion: 'Cancelación de ruido y 30 horas de batería.',
      precio: 79.90,
      imagen: 'assets/productos/audio.jpg',
    ),
    Producto(
      id: 4,
      nombre: 'Smartwatch Fit',
      descripcion: 'Monitor cardíaco, GPS y resistencia al agua.',
      precio: 129.50,
      imagen: 'assets/productos/watch.jpg',
    ),
    Producto(
      id: 5,
      nombre: 'Monitor 27"',
      descripcion: 'Resolución 2K a 144 Hz para trabajo y juegos.',
      precio: 259.00,
      imagen: 'assets/productos/monitor.jpg',
    ),
  ];
}
