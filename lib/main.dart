import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appmovil_integradora1/providers/catalogo_provider.dart';
import 'package:appmovil_integradora1/repository/producto_repository.dart';
import 'package:appmovil_integradora1/routes/app_routes.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';

void main() {
  runApp(
    // Providers disponibles para toda la app
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              CatalogoProvider(ProductoRepository())..cargarProductos(),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
