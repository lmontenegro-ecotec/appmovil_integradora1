import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appmovil_integradora1/repository/perfil_repository.dart';
import 'package:appmovil_integradora1/services/camara_service.dart';
import 'package:appmovil_integradora1/services/notificaciones_service.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';

/// Pantalla de perfil: foto con cámara o galería y manejo de permisos.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final CamaraService _camara = CamaraService();
  final PerfilRepository _perfil = PerfilRepository();

  File? _foto;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _cargarFotoGuardada();
  }

  Future<void> _cargarFotoGuardada() async {
    final foto = await _perfil.leerFoto();
    if (!mounted) return;
    setState(() => _foto = foto);
  }

  /// Flujo completo: permiso -> captura/compresión -> guardado -> vista previa.
  Future<void> _seleccionarFoto(ImageSource origen) async {
    setState(() => _procesando = true);
    try {
      final permiso = await _camara.solicitarPermiso(origen);
      if (!mounted) return;

      switch (permiso) {
        case ResultadoPermiso.denegado:
          _mensaje('Permiso denegado. Lo necesitamos para tu foto de perfil.');
          return;
        case ResultadoPermiso.denegadoPermanente:
          await _dialogoAjustes();
          return;
        case ResultadoPermiso.concedido:
          break;
      }

      final imagen = await _camara.obtenerImagen(origen);
      if (imagen == null) return; // el usuario canceló

      final guardada = await _perfil.guardarFoto(imagen);
      if (!mounted) return;
      setState(() => _foto = guardada ?? imagen);
      _mensaje('Foto de perfil actualizada');
      // Evento clave: foto de perfil actualizada
      NotificacionesService.instancia.mostrar(
        'Foto de perfil actualizada',
        'Tu nueva foto se guardó en el dispositivo.',
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Permiso bloqueado: solo se puede habilitar desde los Ajustes del sistema.
  Future<void> _dialogoAjustes() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso bloqueado'),
        content: const Text(
          'Negaste el permiso de forma permanente. Para usar esta función, '
          'habilítalo en los Ajustes de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _camara.abrirAjustes();
            },
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 70,
              backgroundColor: AppTheme.fondoSuave,
              backgroundImage: _foto != null ? FileImage(_foto!) : null,
              child: _foto == null
                  ? const Icon(Icons.person, size: 70, color: AppTheme.primario)
                  : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Cliente TiendaTec',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _foto == null
                  ? 'Agrega una foto de perfil'
                  : 'Foto guardada en el dispositivo',
              style: const TextStyle(color: AppTheme.textoSecundario),
            ),
            const SizedBox(height: 32),
            if (_procesando) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _procesando
                    ? null
                    : () => _seleccionarFoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Tomar foto con la cámara'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _procesando
                    ? null
                    : () => _seleccionarFoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Elegir de la galería'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'La imagen se comprime (calidad 70 %, máx. 800 px) antes de guardarse.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}
