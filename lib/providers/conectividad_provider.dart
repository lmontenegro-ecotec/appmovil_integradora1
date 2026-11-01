import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:appmovil_integradora1/services/conectividad_service.dart';

/// Estado de la conexión a internet para toda la app (Provider).
class ConectividadProvider extends ChangeNotifier {
  final ConectividadService _servicio;
  StreamSubscription<bool>? _suscripcion;
  Timer? _verificacionPeriodica;

  bool _conectado = true;
  bool get conectado => _conectado;

  /// Acción opcional a ejecutar cuando vuelve la conexión
  /// (por ejemplo, recargar el catálogo).
  VoidCallback? alReconectar;

  ConectividadProvider(this._servicio) {
    _iniciar();
  }

  Future<void> _iniciar() async {
    _actualizar(await _servicio.verificarConexion());

    // 1) Escucha en tiempo real los cambios de red del sistema
    _suscripcion = _servicio.cambios.listen(_actualizar);

    // 2) Verificación periódica de respaldo cada 10 segundos
    _verificacionPeriodica = Timer.periodic(
      const Duration(seconds: 10),
      (_) async => _actualizar(await _servicio.verificarConexion()),
    );
  }

  void _actualizar(bool hayConexion) {
    if (hayConexion == _conectado) return;
    final volvioLaConexion = hayConexion && !_conectado;
    _conectado = hayConexion;
    debugPrint('Conectividad: ${_conectado ? "EN LÍNEA" : "SIN CONEXIÓN"}');
    notifyListeners();
    if (volvioLaConexion) alReconectar?.call();
  }

  @override
  void dispose() {
    // Libera el Stream y el temporizador al destruir el provider
    _suscripcion?.cancel();
    _verificacionPeriodica?.cancel();
    super.dispose();
  }
}
