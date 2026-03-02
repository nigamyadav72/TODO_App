import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5F33E1); // rgba(95, 51, 225)
  static const Color accent = Color(0xFF00D2FF);
  
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Colors.white;
  static const Color bottomBarBackground = Color(0xFFEEE9FF); // rgba(238, 233, 255)
  
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  
  static const Color workTask = Color(0xFFFF7BAC);
  static const Color personalTask = Color(0xFF5AC8FA);
  static const Color studyTask = Color(0xFFFFCC00);
  
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  
  // Decorative blur colors
  static const Color blurYellow = Color(0xFFFFF7CC);
  static const Color blurBlue = Color(0xFFE6F7FF);
  static const Color blurPink = Color(0xFFFFF0F5);
  static const Color blurGreen = Color(0xFFF6FFED);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C38FF), Color(0xFF4A25BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
