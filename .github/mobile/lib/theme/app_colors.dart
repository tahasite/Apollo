import 'package:flutter/material.dart';

class AppColors {
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgCard = Color(0xFF12121A);
  static const Color bgCardHover = Color(0xFF1A1A28);
  static const Color bgSurface = Color(0xFF0F0F18);
  static const Color bgInput = Color(0xFF16161F);
  static const Color borderDim = Color(0xFF1E1E2E);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDim = Color(0xFF475569);

  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPink = Color(0xFFEC4899);

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}