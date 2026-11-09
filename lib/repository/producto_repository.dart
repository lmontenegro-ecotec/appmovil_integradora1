import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appmovil_integradora1/models/producto.dart';
import 'package:appmovil_integradora1/services/tienda_api_service.dart';

/// De dónde se obtuvieron los datos del catálogo.
enum OrigenDatos { red, cache }

/// Copia del catálogo guardada en el dispositivo.
class CatalogoGuardado {
  final List<Producto> productos;
  final DateTime? guardadoEl;
  const CatalogoGuardado(this.productos, this.guardadoEl);
}

/// Capa de datos: une la API pública con la caché local.
/// La interfaz no sabe de dónde vienen los productos.
class ProductoRepository {
  static const String _claveCache = 'catalogo_api_cache';
  static const String _claveFecha = 'catalogo_api_cache_fecha';

  final TiendaApiService _api;

  ProductoRepository({TiendaApiService? api})
    : _api = api ?? TiendaApiService();

  /// Descarga el catálogo desde la API y guarda una copia.
  /// Si falla, propaga la [ApiException] para que el Provider
  /// pase al estado de error.
  Future<List<Producto>> obtenerProductos() async {
    final productos = await _api.obtenerProductos();
    await _guardarEnCache(productos);
    return productos;
  }

  /// Guarda el catálogo descargado (persistencia local con SharedPreferences).
  Future<void> _guardarEnCache(List<Producto> productos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(productos.map((p) => p.toJson()).toList());
      await prefs.setString(_claveCache, json);
      await prefs.setString(_claveFecha, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Caché: no se pudo guardar -> $e');
    }
  }

  /// Lee la última copia guardada; devuelve null si no existe o está dañada.
  Future<CatalogoGuardado?> leerCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_claveCache);
      if (json == null) return null;
      final List<dynamic> datos = jsonDecode(json);
      final productos = datos
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList();
      if (productos.isEmpty) return null;
      final fecha = DateTime.tryParse(prefs.getString(_claveFecha) ?? '');
      return CatalogoGuardado(productos, fecha);
    } catch (e) {
      debugPrint('Caché: no se pudo leer -> $e');
      return null;
    }
  }
}
