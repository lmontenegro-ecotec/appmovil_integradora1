import 'package:flutter/foundation.dart';
import 'package:appmovil_integradora1/models/producto.dart';
import 'package:appmovil_integradora1/repository/producto_repository.dart';

/// Estado del catálogo (gestión de estado con Provider).
/// Separa la lógica de carga de datos de la interfaz.
class CatalogoProvider extends ChangeNotifier {
  final ProductoRepository _repositorio;

  CatalogoProvider(this._repositorio);

  List<Producto> _productos = [];
  bool _cargando = false;
  String? _error;
  OrigenDatos? _origen;
  DateTime? _guardadoEl;

  List<Producto> get productos => _productos;
  bool get cargando => _cargando;
  String? get error => _error;
  OrigenDatos? get origen => _origen;
  DateTime? get guardadoEl => _guardadoEl;

  /// Pide los productos al repositorio y avisa a la interfaz.
  Future<void> cargarProductos() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _repositorio.obtenerProductos();
      _productos = resultado.productos;
      _origen = resultado.origen;
      _guardadoEl = resultado.guardadoEl;
    } catch (e) {
      _error = 'No se pudo cargar el catálogo';
      debugPrint('CatalogoProvider: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
