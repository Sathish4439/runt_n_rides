import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Category Colors
  static const Color enquiryPrimary = Color(0xFF1565C0); // Blue[700]
  static const Color enquirySecondary = Color(0xFF42A5F5); // Blue[400]

  static const Color bookingPrimary = Color(0xFF2E7D32); // Green[700]
  static const Color bookingSecondary = Color(0xFF66BB6A); // Green[400]

  static const Color ongoingPrimary = Color(0xFF6A1B9A); // Purple[700]
  static const Color ongoingSecondary = Color(0xFFBA68C8); // Purple[400]

  static const Color followUpPrimary = Color(0xFFF57C00); // Orange[700]
  static const Color followUpSecondary = Color(0xFFFFB74D); // Orange[400]

  // 🌐 Global Colors
  static const Color background = Color(0xFFF5F5F5); // Light grey background
  static const Color surface = Colors.white; // Card/sheets
  static const Color error = Colors.redAccent;

  // 📝 Text
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textOnPrimary = Colors.white;

  // ⏺ UI Shape
  static const double borderRadius = 12.0;

  /// ✅ Main App Theme
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: enquiryPrimary, // Default App Brand Color
      colorScheme: ColorScheme(
        primary: enquiryPrimary,
        primaryContainer: enquirySecondary,
        secondary: bookingPrimary,
        secondaryContainer: bookingSecondary,
        background: background,
        surface: surface,
        error: error,
        onPrimary: textOnPrimary,
        onSecondary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: enquiryPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: bookingPrimary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: enquiryPrimary,
          foregroundColor: textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: bookingPrimary,
          side: const BorderSide(color: bookingPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
