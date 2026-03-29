import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ─────────────────────────────────────────────────────  // Core colors
  static const Color bg = Color(0xFF070B19);        // Deep cyber black
  static const Color surface = Color(0xFF11172B);   // Dark slate blue
  static const Color card = Color(0xFF1E2642);      // Elevated panel
  
  // Accents
  static const Color primary = Color(0xFF00E5FF);   // Cyber Cyan
  static const Color secondary = Color(0xFFB000FF); // Neon Purple
  
  // States
  static const Color safe = Color(0xFF00E676);      // Neon Green
  static const Color suspicious = Color(0xFFFFD600); // Neon Yellow
  static const Color scam = Color(0xFFFF1744);      // Neon Red
  static const Color textPrimary = Color(0xFFEAEEFF);
  static const Color textSecondary = Color(0xFF7C85A8);
  static const Color border = Color(0xFF252D45);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surface,
          background: bg,
          error: scam,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: bg,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );

  // ── Gradient helpers ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color resultColor(String result) {
    switch (result.toLowerCase()) {
      case 'safe':
        return safe;
      case 'suspicious':
        return suspicious;
      case 'scam':
        return scam;
      default:
        return textSecondary;
    }
  }
}
