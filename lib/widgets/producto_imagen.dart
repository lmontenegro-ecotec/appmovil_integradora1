import 'package:flutter/material.dart';
import 'package:appmovil_integradora1/models/producto.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';

/// Muestra la imagen del producto: de internet (API) o de los assets.
/// Mientras descarga muestra un indicador y, si falla, un ícono.
class ProductoImagen extends StatelessWidget {
  final Producto producto;
  final double? alto;

  const ProductoImagen({super.key, required this.producto, this.alto});

  @override
  Widget build(BuildContext context) {
    if (!producto.imagenEsRemota) {
      return Image.asset(
        producto.imagen,
        height: alto,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _sinImagen(),
      );
    }

    return Image.network(
      producto.imagen,
      height: alto,
      width: double.infinity,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progreso) {
        if (progreso == null) return child;
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) => _sinImagen(),
    );
  }

  Widget _sinImagen() => Container(
    height: alto,
    color: AppTheme.fondoSuave,
    alignment: Alignment.center,
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: AppTheme.textoSecundario,
      size: 40,
    ),
  );
}
