import 'package:flutter/material.dart';

/// Tema centralizado de TiendaTec.
/// Toda la paleta de colores de la aplicación se define aquí,
/// así las pantallas no usan colores "quemados" y el branding es uniforme.
class AppTheme {
  // Paleta de marca
  static const Color primario = Color(0xFF3730A3); // índigo
  static const Color primarioOscuro = Color(0xFF1E1B4B); // índigo oscuro (splash / AppBar)
  static const Color acento = Color(0xFFFACC15); // amarillo eléctrico
  static const Color fondo = Color(0xFFF5F5FA);
  static const Color fondoSuave = Color(0xFFE0E7FF);
  static const Color textoSecundario = Color(0xFF6B7280);
  static const Color favorito = Color(0xFFE11D48);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primario,
      primary: primario,
      secondary: acento,
    ),
    scaffoldBackgroundColor: fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: primarioOscuro,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: acento,
      foregroundColor: primarioOscuro,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primario,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: primarioOscuro,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
