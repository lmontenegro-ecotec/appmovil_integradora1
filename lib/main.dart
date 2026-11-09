import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appmovil_integradora1/providers/catalogo_provider.dart';
import 'package:appmovil_integradora1/providers/conectividad_provider.dart';
import 'package:appmovil_integradora1/services/conectividad_service.dart';
import 'package:appmovil_integradora1/services/notificaciones_service.dart';
import 'package:appmovil_integradora1/repository/producto_repository.dart';
import 'package:appmovil_integradora1/routes/app_routes.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';

Future<void> main() async {
  // Necesario antes de usar plugins nativos (conectividad, notificaciones)
  WidgetsFlutterBinding.ensureInitialized();

  final notificaciones = NotificacionesService.instancia;
  await notificaciones.inicializar();

  final catalogo = CatalogoProvider(ProductoRepository())..cargarProductos();
  final conectividad = ConectividadProvider(ConectividadService())
    // Evento clave: se pierde la conexión
    ..alPerderConexion = () {
      notificaciones.mostrar(
        'Sin conexión a internet',
        'Puedes ver el catálogo guardado mientras vuelve la señal.',
      );
    }
    // Evento clave: vuelve la conexión -> recarga el catálogo y avisa
    ..alReconectar = () {
      catalogo.cargarProductos();
      notificaciones.mostrar(
        'Conexión restablecida',
        'El catálogo de TiendaTec se actualizó desde internet.',
      );
    };

  runApp(
    // Providers disponibles para toda la app
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: catalogo),
        ChangeNotifierProvider.value(value: conectividad),
      ],
      child: const MyApp(),
    ),
  );

  // Se pide el permiso de notificaciones cuando la app ya está en pantalla
  notificaciones.solicitarPermiso();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TiendaTec',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // home: const HomeScreen(), -> reemplazado por rutas con nombre
      initialRoute: AppRoutes.inicio,
      routes: AppRoutes.rutas,
    );
  }
}
