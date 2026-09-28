import 'package:flutter/material.dart';

class OnionSureColors {
  // Primary brand palette (Fresh Onion Green & APMC Agricultural Emerald)
  static const Color primaryGreen = Color(0xFF15803D); // Emerald 700
  static const Color primaryDark = Color(0xFF14532D);  // Emerald 900
  static const Color primaryLight = Color(0xFF22C55E); // Green 500
  static const Color surfaceLight = Color(0xFFF8FAFC); // Slate 50
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Status & Grade Tones
  static const Color gradeA = Color(0xFF16A34A); // Green
  static const Color gradeB = Color(0xFF2563EB); // Blue
  static const Color gradeC = Color(0xFFD97706); // Amber
  static const Color gradeReject = Color(0xFFDC2626); // Red

  // Neutral tones
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
}

class OnionSureTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: OnionSureColors.primaryGreen,
        brightness: Brightness.light,
        primary: OnionSureColors.primaryGreen,
        onPrimary: Colors.white,
        surface: OnionSureColors.surfaceLight,
        onSurface: OnionSureColors.textDark,
      ),
      scaffoldBackgroundColor: OnionSureColors.surfaceLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: OnionSureColors.cardWhite,
        foregroundColor: OnionSureColors.textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: OnionSureColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardTheme(
        color: OnionSureColors.cardWhite,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: OnionSureColors.borderLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OnionSureColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OnionSureColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OnionSureColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OnionSureColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
