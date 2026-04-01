import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  light,
  dark,
  neon
}

class AppTheme {
  // --- TEMA CLARO (Minimalista) ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF10B981), // Verde Esmeralda Moderno
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF10B981),
        secondary: const Color(0xFF34D399),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // --- TEMA OSCURO (Elegante y Moderno) ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF8B5CF6), // Morado Profundo
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF8B5CF6),
        secondary: const Color(0xFFA78BFA),
        surface: const Color(0xFF1E1E2C),
      ),
      scaffoldBackgroundColor: const Color(0xFF12121A),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E2C),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }

  // --- TEMA NEON (Futurista brillante) ---
  static ThemeData get neonTheme {
    final neonCyan = const Color(0xFF00FFE5);
    final neonPink = const Color(0xFFFF00A0);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: neonCyan,
      colorScheme: ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPink,
        surface: const Color(0xFF0F0B1A), // Fondo de tarjetas muy oscuro
      ),
      scaffoldBackgroundColor: const Color(0xFF030006), // Negro Profundo
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: neonCyan,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: neonCyan),
        titleTextStyle: TextStyle(
          color: neonCyan, 
          fontSize: 26, 
          fontWeight: FontWeight.w800, 
          letterSpacing: 1.5,
          shadows: [Shadow(color: neonCyan.withValues(alpha: 0.6), blurRadius: 10)]
        ),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0F0B1A),
        elevation: 10,
        shadowColor: neonCyan.withValues(alpha: 0.3), // Glow en las tarjetas
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: neonCyan.withValues(alpha: 0.5), width: 1.0),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: neonCyan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: neonCyan, width: 2.5)
        ),
        elevation: 15,
      ),
    );
  }
}
