import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appmovil_integradora1/models/producto.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('TiendaTec'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: catalogo.estado == EstadoCatalogo.cargando
                ? null
                : () => context.read<CatalogoProvider>().cargarProductos(),
          ),
          IconButton(
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner que aparece solo cuando no hay internet
          const OfflineBanner(),
          Expanded(
            // Cada estado de la petición dibuja una pantalla distinta
            child: switch (catalogo.estado) {
              EstadoCatalogo.cargando => const CargandoView(),
              EstadoCatalogo.error => RefreshIndicator(
                onRefresh: () => context
                    .read<CatalogoProvider>()
                    .cargarProductos(mostrarCargando: false),
                child: ErrorView(
                  mensaje: catalogo.mensajeError,
                  onReintentar: () =>
                      context.read<CatalogoProvider>().cargarProductos(),
                  onVerGuardado: catalogo.hayRespaldo
                      ? () => context
                            .read<CatalogoProvider>()
                            .usarCatalogoGuardado()
                      : null,
                ),
              ),
              EstadoCatalogo.exito => _CatalogoExito(catalogo: catalogo),
            },
          ),
        ],
      ),
    );
  }
}

/// Estado "Éxito": encabezado + cuadrícula con pull-to-refresh.
class _CatalogoExito extends StatelessWidget {
  final CatalogoProvider catalogo;
  const _CatalogoExito({required this.catalogo});

  @override
  Widget build(BuildContext context) {
    final productos = catalogo.productos;

    return RefreshIndicator(
      // Deslizar hacia abajo vuelve a consultar la API
      onRefresh: () => context.read<CatalogoProvider>().cargarProductos(
        mostrarCargando: false,
      ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Encabezado(catalogo: catalogo)),
          if (productos.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('La API no devolvió productos.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return ProductoCard(
                    producto: producto,
                    onTap: () => _abrirDetalle(context, producto),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _abrirDetalle(BuildContext context, Producto producto) {
    // Navegación por nombre enviando el producto como argumento
    Navigator.pushNamed(context, AppRoutes.detalle, arguments: producto);
  }
}

class _Encabezado extends StatelessWidget {
  final CatalogoProvider catalogo;
  const _Encabezado({required this.catalogo});

  @override
  Widget build(BuildContext context) {
    final origen = switch (catalogo.origen) {
      OrigenDatos.red => 'Datos en vivo desde la API DummyJSON',
      OrigenDatos.cache =>
        'Sin conexión: catálogo guardado${catalogo.guardadoEl != null ? ' el ${_formatoFecha(catalogo.guardadoEl!)}' : ''}',
      null => '',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppTheme.fondoSuave,
      child: Row(
        children: [
          Icon(
            catalogo.origen == OrigenDatos.cache
                ? Icons.cloud_off
                : Icons.cloud_done,
            size: 40,
            color: AppTheme.primario,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('${catalogo.productos.length} productos disponibles'),
                Text(
                  origen,
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
    );
  }

  /// Formato corto dd/mm hh:mm para mostrar la fecha de la caché.
  static String _formatoFecha(DateTime f) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)} ${dos(f.hour)}:${dos(f.minute)}';
  }
}
