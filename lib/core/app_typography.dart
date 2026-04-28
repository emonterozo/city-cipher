import 'package:flutter/material.dart';
import 'theme.dart';

class AppTypography {
  static const String _font = 'Poppins';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font,
    color: CityCipherTheme.foreground,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    fontSize: 32,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _font,
    color: CityCipherTheme.foreground,
    fontWeight: FontWeight.w700,
    fontSize: 24,
  );

   static const TextStyle titleMedium = TextStyle(
    fontFamily: _font,
    color: CityCipherTheme.foreground,
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font,
    color: CityCipherTheme.foreground,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font,
    color: CityCipherTheme.mutedForeground,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font,
    color: CityCipherTheme.mutedForeground,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
