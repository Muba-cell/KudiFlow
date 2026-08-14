import 'package:flutter/material.dart';

class AppTheme {
  static const Color eclipseMint = Color(0xFF182927);
  static const Color auroraDust = Color(0xFFD9D6E8);
  static const Color moonlitMint = Color(0xFF9FFFE0);
  static const Color cloudWhite = Color(0xFFFBFBFD);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cloudWhite,

      colorScheme: const ColorScheme.light(
        primary: eclipseMint,
        secondary: moonlitMint,
        surface: cloudWhite,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: moonlitMint,
          foregroundColor: eclipseMint,
          elevation: 0,
        ),
      ),
    );
  }
}