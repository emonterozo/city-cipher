import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CityCipherTheme {
  // Brand Colors
  static const Color primaryRed = Color(0xFFDC143C); // Crimson Red
  static const Color background = Color(0xFFF8F9FA); // Off-White Studio
  static const Color surface = Colors.white;
  static const Color textMain = Color(
    0xFF1A1A1A,
  ); // Deep Charcoal (Better than pure black)
  static const Color textMuted = Color(0xFF757575);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryRed,
      primary: primaryRed,
      surface: surface,
    ),

    // --- TEXT THEME (The secret to premium white backgrounds) ---
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        color: textMain,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
      ),
      titleLarge: GoogleFonts.outfit(
        color: textMain,
        fontWeight: FontWeight.w800,
        fontSize: 22,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.inter(color: textMain, fontSize: 16),
      labelLarge: GoogleFonts.inter(
        color: textMuted,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2, // Good for those small section headers
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor:
          Colors.transparent, // Prevents weird M3 colors on scroll
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: textMain),
      titleTextStyle: GoogleFonts.outfit(
        color: textMain,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),

    // Card Theme for your store logos
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
    ),
  );
}
