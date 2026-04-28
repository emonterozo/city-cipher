import 'package:flutter/material.dart';

class CityCipherTheme {
  static const Color background = Color(0xFF0D1B2A);
  static const Color foreground = Color(0xFFF8FAFC);
  static const Color primary = Color(0xFFFBBF24);
  static const Color primaryForeground = Color(0xFF451A03);
  static const Color secondary = Color(0xFF2DD4BF);
  static const Color secondaryForeground = Color(0xFF042F2E);
  static const Color mutedForeground = Color(0xFF94A3B8);
  static const Color accent = Color(0xFF1E293B);
  static const Color card = Color(0xFF16243A);
  static const Color cardForeground = Color(0xFFF8FAFC);
  static const Color border = Color(0xFF1E314B);
  static const Color input = Color(0xFF16243A);

  static const String fontFamily = 'Poppins';

  static ThemeData darkTheme = ThemeData(
    fontFamily: fontFamily,
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      surface: background,
      onSurface: foreground,
      outline: border,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
    ),

    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
    ),
  );
}