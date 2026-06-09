import 'package:flutter/material.dart';

class AppTheme {
  static const brandBlue = Color(0xFF3135FF);
  static const brandNavy = Color(0xFF001B70);
  static const brandSky = Color(0xFFE9ECFF);
  static const brandInk = Color(0xFF07133D);
  static const brandGold = Color(0xFFF4B740);
  static const brandCoral = Color(0xFFE8583D);
  static const background = Color(0xFFF5F7FF);
  static const border = Color(0xFFDDE3FF);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandBlue,
        primary: brandBlue,
        secondary: brandNavy,
        tertiary: brandGold,
        surface: background,
        onSurface: brandInk,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: brandNavy,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD8DEE8)),
        ),
      ),
    );
  }
}
