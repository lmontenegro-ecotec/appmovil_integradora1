import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Resultado de pedir un permiso al usuario.
enum ResultadoPermiso { concedido, denegado, denegadoPermanente }

/// Servicio nativo de cámara y galería (desacoplado de la interfaz).
/// - Pide los permisos en tiempo de ejecución (permission_handler).
/// - Captura o elige la imagen y la comprime (image_picker).
class CamaraService {
  final ImagePicker _picker = ImagePicker();

  /// Solicita el permiso correspondiente al origen elegido.
  Future<ResultadoPermiso> solicitarPermiso(ImageSource origen) async {
    final permiso =
        origen == ImageSource.camera ? Permission.camera : Permission.photos;
    try {
      var estado = await permiso.status;
      if (estado.isGranted || estado.isLimited) {
        return ResultadoPermiso.concedido;
      }

      // Muestra el diálogo nativo del sistema
      estado = await permiso.request();
      debugPrint('Permiso ${origen.name}: $estado');

      if (estado.isGranted || estado.isLimited) {
        return ResultadoPermiso.concedido;
      }
      if (estado.isPermanentlyDenied) {
        return ResultadoPermiso.denegadoPermanente;
      }
      return ResultadoPermiso.denegado;
    } catch (e) {
      debugPrint('CamaraService: error al solicitar permiso -> $e');
      return ResultadoPermiso.denegado;
    }
  }

  /// Abre la cámara o la galería y devuelve la imagen ya comprimida.
  /// Devuelve null si el usuario cancela.
  Future<File?> obtenerImagen(ImageSource origen) async {
    try {
      final archivo = await _picker.pickImage(
        source: origen,
        imageQuality: 70, // compresión JPEG al 70 %
        maxWidth: 800, // redimensiona a máximo 800 px
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.front,
      );
      if (archivo == null) return null;

      final imagen = File(archivo.path);
      final kb = (await imagen.length()) / 1024;
      debugPrint('Imagen obtenida y comprimida: ${kb.toStringAsFixed(1)} KB');
      return imagen;
    } on PlatformException catch (e) {
      debugPrint('CamaraService: error de plataforma -> ${e.code}');
      return null;
    } catch (e) {
      debugPrint('CamaraService: error al obtener la imagen -> $e');
      return null;
    }
  }

  /// Abre los ajustes de la app para que el usuario habilite el permiso.
  Future<void> abrirAjustes() => openAppSettings();
}
