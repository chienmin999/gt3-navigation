import 'package:flutter/material.dart';

/// Theme sáng & tối cho ứng dụng dẫn đường
class AppTheme {
  AppTheme._();

  // === Màu chính ===
  static const Color _primaryColor = Color(0xFF1B5E20); // Xanh lá đậm
  static const Color _accentColor = Color(0xFF4CAF50); // Xanh lá
  static const Color _navBlue = Color(0xFF1565C0); // Xanh dương cho route

  // === Light Theme ===
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: _primaryColor,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _accentColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // === Dark Theme (phù hợp khi lái xe ban đêm) ===
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: _primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _accentColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // === Màu dùng riêng cho navigation UI ===
  static const Color routeLineColor = _navBlue;
  static const Color maneuverAlertColor = Colors.orange;
  static const Color arrivedColor = _accentColor;
}
