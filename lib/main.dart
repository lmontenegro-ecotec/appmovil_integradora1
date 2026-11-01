import 'package:flutter/material.dart';
import 'package:appmovil_integradora1/routes/app_routes.dart';
import 'package:appmovil_integradora1/theme/app_theme.dart';

void main() => runApp(const MyApp());

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
