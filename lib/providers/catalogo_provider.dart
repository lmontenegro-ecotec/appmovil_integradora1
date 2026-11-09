import 'package:flutter/foundation.dart';
import 'package:appmovil_integradora1/models/producto.dart';
import 'package:appmovil_integradora1/repository/producto_repository.dart';
import 'package:appmovil_integradora1/services/tienda_api_service.dart';

/// Los tres estados de la petición a la API.
enum EstadoCatalogo { cargando, exito, error }

/// Estado del catálogo (gestión de estado con Provider).
/// La interfaz solo lee [estado] y dibuja la pantalla que corresponde.
class CatalogoProvider extends ChangeNotifier {
  final ProductoRepository _repositorio;

  CatalogoProvider(this._repositorio);

  EstadoCatalogo _estado = EstadoCatalogo.cargando;
  List<Producto> _productos = [];
  String _mensajeError = '';
  OrigenDatos? _origen;
  DateTime? _guardadoEl;
  CatalogoGuardado? _respaldo;

  EstadoCatalogo get estado => _estado;
  List<Producto> get productos => List.unmodifiable(_productos);
  String get mensajeError => _mensajeError;
  OrigenDatos? get origen => _origen;
  DateTime? get guardadoEl => _guardadoEl;

  /// true si hay una copia guardada que se puede mostrar sin conexión.
  bool get hayRespaldo => _respaldo != null;

  /// Pide los productos a la API.
  /// [mostrarCargando] es false en el pull-to-refresh, porque ahí
  /// el RefreshIndicator ya muestra su propio indicador.
  Future<void> cargarProductos({bool mostrarCargando = true}) async {
    if (mostrarCargando) {
      _estado = EstadoCatalogo.cargando;
      notifyListeners();
    }

    try {
      _productos = await _repositorio.obtenerProductos();
      _origen = OrigenDatos.red;
      _guardadoEl = null;
      _estado = EstadoCatalogo.exito;
    } on ApiException catch (e) {
      _mensajeError = e.mensaje;
      _respaldo = await _repositorio.leerCache();
      _estado = EstadoCatalogo.error;
      debugPrint('CatalogoProvider: ${e.mensaje}');
    } catch (e) {
      _mensajeError = 'Ocurrió un error inesperado al cargar el catálogo.';
      _respaldo = await _repositorio.leerCache();
      _estado = EstadoCatalogo.error;
      debugPrint('CatalogoProvider: $e');
    }
    notifyListeners();
  }

  /// Desde la pantalla de error: muestra la última copia guardada.
  void usarCatalogoGuardado() {
    final respaldo = _respaldo;
    if (respaldo == null) return;
    _productos = respaldo.productos;
    _origen = OrigenDatos.cache;
    _guardadoEl = respaldo.guardadoEl;
    _estado = EstadoCatalogo.exito;
    notifyListeners();
  }
}
