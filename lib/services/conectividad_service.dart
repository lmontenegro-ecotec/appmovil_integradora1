import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Servicio nativo de conectividad (desacoplado de la interfaz).
/// 1) connectivity_plus escucha en tiempo real los cambios de red del sistema
///    (Wi-Fi, datos móviles, modo avión).
/// 2) Como tener una interfaz de red activa no garantiza tener internet
///    (ej. el emulador conserva una red virtual en modo avión), se confirma
///    con una consulta DNS real.
class ConectividadService {
  final Connectivity _connectivity = Connectivity();

  /// Stream que emite true/false cada vez que cambia el estado de la red.
  Stream<bool> get cambios =>
      _connectivity.onConnectivityChanged.asyncMap(_evaluar);

  /// Consulta el estado actual de la red.
  Future<bool> verificarConexion() async {
    try {
      final resultado = await _connectivity.checkConnectivity();
      return _evaluar(resultado);
    } catch (e) {
      debugPrint('ConectividadService: no se pudo verificar la red -> $e');
      return false;
    }
  }

  Future<bool> _evaluar(List<ConnectivityResult> resultados) async {
    final hayInterfaz = resultados.any((r) => r != ConnectivityResult.none);
    if (!hayInterfaz) return false;
    return _hayInternetReal();
  }

  /// Comprueba que realmente se pueda llegar a internet.
  Future<bool> _hayInternetReal() async {
    try {
      final respuesta = await InternetAddress.lookup('raw.githubusercontent.com')
          .timeout(const Duration(seconds: 3));
      return respuesta.isNotEmpty && respuesta.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      debugPrint('ConectividadService: error al comprobar internet -> $e');
      return false;
    }
  }
}
