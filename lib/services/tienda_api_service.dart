import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:appmovil_integradora1/models/producto.dart';

/// Error controlado de la capa de red, con un mensaje apto para el usuario.
class ApiException implements Exception {
  final String mensaje;
  const ApiException(this.mensaje);

  @override
  String toString() => 'ApiException: $mensaje';
}

/// Capa de servicios: consume la API REST pública DummyJSON.
/// No requiere token ni autenticación.
/// Documentación: https://dummyjson.com/docs/products
class TiendaApiService {
  static const String _host = 'dummyjson.com';

  /// Categorías de tecnología de DummyJSON que vende TiendaTec.
  static const List<String> categorias = [
    'smartphones',
    'laptops',
    'tablets',
    'mobile-accessories',
  ];

  /// Solo se piden los campos que usa la app (menos datos transferidos).
  static const String _campos =
      'title,description,price,thumbnail,category,rating';

  final http.Client _cliente;

  TiendaApiService({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  /// URL del endpoint de una categoría, por ejemplo:
  /// https://dummyjson.com/products/category/smartphones?select=...
  static Uri urlCategoria(String categoria) => Uri.https(
    _host,
    '/products/category/$categoria',
    {'select': _campos},
  );

  /// Pide todas las categorías al mismo tiempo (Future.wait) y une
  /// los resultados en una sola lista.
  Future<List<Producto>> obtenerProductos() async {
    final listas = await Future.wait(categorias.map(_obtenerCategoria));
    final productos = listas.expand((lista) => lista).toList();
    debugPrint('API: ${productos.length} productos recibidos de $_host');
    return productos;
  }

  /// Petición GET asíncrona de una categoría. Devuelve sus productos o lanza
  /// [ApiException] si no hay red, se agota el tiempo, el servidor
  /// responde con error o el JSON no tiene el formato esperado.
  Future<List<Producto>> _obtenerCategoria(String categoria) async {
    try {
      final respuesta = await _cliente
          .get(urlCategoria(categoria))
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode != 200) {
        throw ApiException(
          'El servidor respondió con error ${respuesta.statusCode}.',
        );
      }

      // La respuesta es un objeto: { "products": [...], "total": 16, ... }
      final datos =
          jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
      final lista = datos['products'] as List<dynamic>? ?? [];

      return lista
          .map((e) => Producto.fromApiJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const ApiException(
        'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.',
      );
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servidor de productos.',
      );
    } on FormatException {
      throw const ApiException('La respuesta del servidor no es válida.');
    } on TypeError {
      throw const ApiException('La respuesta del servidor no es válida.');
    }
  }
}
