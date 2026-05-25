import 'package:flutter/material.dart';

/// Weladti Design System — Color Palette
/// Soft feminine, medical-grade, emotionally supportive
class AppColors {
  AppColors._();

  // ── Brand Gradient ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE91E8C);       // Rose Pink
  static const Color primaryLight = Color(0xFFF48FB1);  // Soft Pink
  static const Color primaryDark = Color(0xFFC2185B);   // Deep Rose

  static const Color secondary = Color(0xFF9C27B0);     // Warm Purple
  static const Color secondaryLight = Color(0xFFCE93D8);
  static const Color secondaryDark = Color(0xFF6A1B9A);

  static const Color accent = Color(0xFFFF8F00);        // Warm Amber (alerts)
  static const Color accentLight = Color(0xFFFFCC02);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFF8FB);    // Warm white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFCEFF6);
  static const Color cardBg = Color(0xFFFFFFFF);

  // ── Risk Colors ───────────────────────────────────────────────────────────
  static const Color riskLow = Color(0xFF4CAF50);
  static const Color riskModerate = Color(0xFFFF9800);
  static const Color riskHigh = Color(0xFFF44336);
  static const Color riskCritical = Color(0xFF9C27B0);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D1B2E);   // Dark plum
  static const Color textSecondary = Color(0xFF6B4E71); // Muted purple
  static const Color textHint = Color(0xFFB39DBE);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const Color border = Color(0xFFEDD8F0);
  static const Color divider = Color(0xFFF3E5F5);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFFFF8FB), Color(0xFFF3E5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient safeGradient = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF9A9A), Color(0xFFF44336)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primary.withOpacity(0.10),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Risk to Color mapping ─────────────────────────────────────────────────
  static Color riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return riskLow;
      case 'moderate':
        return riskModerate;
      case 'high':
        return riskHigh;
      case 'critical':
        return riskCritical;
      default:
        return riskLow;
    }
  }

  static String riskLabelAr(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 'خطر منخفض';
      case 'moderate':
        return 'خطر متوسط';
      case 'high':
        return 'خطر مرتفع';
      case 'critical':
        return 'خطر حرج';
      default:
        return 'غير محدد';
    }
  }
}
