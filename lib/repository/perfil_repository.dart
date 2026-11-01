import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia de la foto de perfil en el dispositivo.
/// La imagen se copia a la carpeta privada de la app y su ruta
/// se guarda en SharedPreferences para recuperarla al reabrir la app.
class PerfilRepository {
  static const String _claveFoto = 'foto_perfil_ruta';

  Future<File?> guardarFoto(File imagen) async {
    try {
      final carpeta = await getApplicationDocumentsDirectory();
      final nombre = 'perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final copia = await imagen.copy('${carpeta.path}/$nombre');

      final prefs = await SharedPreferences.getInstance();
      final anterior = prefs.getString(_claveFoto);
      await prefs.setString(_claveFoto, copia.path);

      // Elimina la foto anterior para no acumular archivos
      if (anterior != null && anterior != copia.path) {
        final archivoAnterior = File(anterior);
        if (await archivoAnterior.exists()) await archivoAnterior.delete();
      }
      debugPrint('Perfil: foto guardada en ${copia.path}');
      return copia;
    } catch (e) {
      debugPrint('Perfil: no se pudo guardar la foto -> $e');
      return null;
    }
  }

  Future<File?> leerFoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ruta = prefs.getString(_claveFoto);
      if (ruta == null) return null;
      final archivo = File(ruta);
      return await archivo.exists() ? archivo : null;
    } catch (e) {
      debugPrint('Perfil: no se pudo leer la foto -> $e');
      return null;
    }
  }
}
