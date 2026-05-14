import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFDFAF6);
  static const surface = Colors.white;
  static const text = Color(0xFF2C2416);
  static const muted = Color(0xFF8A7A6A);
  static const primary = Color(0xFF6B5D4F);
  static const secondary = Color(0xFF7A9D8F);
  static const warm = Color(0xFFF4EBE1);
  static const softGreen = Color(0xFFE8F1ED);
  static const border = Color(0xFFE8DFD5);
  static const danger = Color(0xFFC45B4F);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9F4ED),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.warm,
        selectedColor: AppColors.primary,
        side: BorderSide.none,
        labelStyle: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}