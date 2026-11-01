import 'package:flutter/material.dart';
import 'package:appmovil_integradora1/models/producto.dart';
import 'package:appmovil_integradora1/services/notificaciones_service.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';

class DetalleScreen extends StatefulWidget {
  final Producto producto;
  const DetalleScreen({super.key, required this.producto});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  bool favorito = false;

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        actions: [
          IconButton(
            icon: Icon(favorito ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                favorito = !favorito;
              });
              // Evento clave: producto agregado a favoritos
              if (favorito) {
                NotificacionesService.instancia.mostrar(
                  'Agregado a favoritos',
                  '${producto.nombre} se guardó en tus favoritos.',
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                producto.imagen,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              producto.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${producto.precio.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: AppTheme.primario),
            ),
            const SizedBox(height: 16),
            Text(producto.descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Código de producto: ${producto.id}',
              style: const TextStyle(color: AppTheme.textoSecundario),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  favorito ? Icons.favorite : Icons.favorite_border,
                  color: AppTheme.favorito,
                ),
                const SizedBox(width: 8),
                Text(favorito ? 'En tus favoritos' : 'Sin marcar'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al catálogo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
