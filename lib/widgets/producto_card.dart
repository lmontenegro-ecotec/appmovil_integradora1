import 'package:flutter/material.dart';
import 'package:appmovil_integradora1/models/producto.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';
import 'package:appmovil_integradora1/widgets/producto_imagen.dart';

/// Tarjeta de producto para la cuadrícula del catálogo.
class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback? onTap;

  const ProductoCard({super.key, required this.producto, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: ProductoImagen(producto: producto),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${producto.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.primario,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(
                        producto.calificacion.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
