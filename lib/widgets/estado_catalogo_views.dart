import 'package:flutter/material.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';

/// Estado "Cargando": se muestra mientras llega la respuesta de la API.
class CargandoView extends StatelessWidget {
  const CargandoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando productos...'),
          SizedBox(height: 4),
          Text(
            'Consultando la API pública DummyJSON',
            style: TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
          ),
        ],
      ),
    );
  }
}

/// Estado "Error": mensaje claro, botón para reintentar y, si existe,
/// acceso al último catálogo guardado en el dispositivo.
class ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;
  final VoidCallback? onVerGuardado;

  const ErrorView({
    super.key,
    required this.mensaje,
    required this.onReintentar,
    this.onVerGuardado,
  });

  @override
  Widget build(BuildContext context) {
    // ListView para que también funcione el pull-to-refresh en este estado
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.wifi_off_rounded, size: 72, color: Colors.redAccent),
        const SizedBox(height: 16),
        const Text(
          'No pudimos cargar el catálogo',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textoSecundario),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onReintentar,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
        if (onVerGuardado != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onVerGuardado,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Ver catálogo guardado'),
          ),
        ],
      ],
    );
  }
}
