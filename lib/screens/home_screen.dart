import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appmovil_integradora1/providers/catalogo_provider.dart';
import 'package:appmovil_integradora1/repository/producto_repository.dart';
import 'package:appmovil_integradora1/routes/app_routes.dart';
import 'package:appmovil_integradora1/widgets/widgets.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha el estado del catálogo: se redibuja cuando cambia
    final catalogo = context.watch<CatalogoProvider>();
    final productos = catalogo.productos;

    return Scaffold(
      appBar: AppBar(title: const Text('TiendaTec')),
      body: Column(
        children: [
          // Banner que aparece solo cuando no hay internet
          const OfflineBanner(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.fondoSuave,
            child: Row(
              children: [
                const Icon(Icons.devices, size: 40, color: AppTheme.primario),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${productos.length} productos disponibles'),
                      if (catalogo.origen != null)
                        Text(
                          catalogo.origen == OrigenDatos.red
                              ? 'Catálogo actualizado desde internet'
                              : 'Catálogo local de respaldo',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: catalogo.cargando
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    // Deslizar hacia abajo vuelve a cargar el catálogo
                    onRefresh: catalogo.cargarProductos,
                    child: ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return ProductoCard(
                          producto: producto,
                          onTap: () {
                            debugPrint(
                              'Navegando al detalle con producto id=${producto.id} (${producto.nombre})',
                            );
                            // Navegación por nombre enviando el producto como argumento
                            Navigator.pushNamed(
                              context,
                              AppRoutes.detalle,
                              arguments: producto,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tenemos ${productos.length} productos en catálogo',
              ),
            ),
          );
        },
        icon: const Icon(Icons.info_outline),
        label: const Text('Info'),
      ),
    );
  }
}
