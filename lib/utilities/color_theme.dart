import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF0E0E0E);
  static const Color card = Color(0xFF1C1C1E);
  static const Color accentMint = Color(0xFFB4F1C1);
  static const Color accentYellow = Color(0xFFFFD700);
  static const Color errorRed = Color(0xFFFF5A5F);
  static const Color softPurple = Color(0xFFD0C6F6);

  static ThemeData get darkTheme {
    return ThemeData(
      // use colors from above
      scaffoldBackgroundColor: background,
      primaryColor: accentYellow,
      cardColor: card,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentYellow,
        foregroundColor: Colors.black,
      ),
      colorScheme: const ColorScheme.dark(
        primary: accentYellow,
        secondary: accentMint,
        error: errorRed,
      ),
      // other theme settings...
    );
  }
}
