import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Arabic Font (Tajawal) — Primary for the app ───────────────────────────
  static TextStyle arabicDisplay({
    double size = 32,
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w800,
  }) =>
      TextStyle(
        fontFamily: 'Tajawal',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.3,
      );

  static TextStyle arabicHeadline({
    double size = 22,
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w700,
  }) =>
      TextStyle(
        fontFamily: 'Tajawal',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.4,
      );

  static TextStyle arabicBody({
    double size = 15,
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: 'Tajawal',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.6,
      );

  static TextStyle arabicCaption({
    double size = 12,
    Color color = AppColors.textSecondary,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: 'Tajawal',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.5,
      );

  // ── English Font (Poppins) — Numbers and English labels ──────────────────
  static TextStyle number({
    double size = 28,
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w700,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle label({
    double size = 13,
    Color color = AppColors.textSecondary,
    FontWeight weight = FontWeight.w500,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  // ── Convenience getters ───────────────────────────────────────────────────
  static TextStyle get displayLarge => arabicDisplay(size: 36);
  static TextStyle get display => arabicDisplay(size: 28);
  static TextStyle get headline1 => arabicHeadline(size: 24);
  static TextStyle get headline2 => arabicHeadline(size: 20);
  static TextStyle get headline3 => arabicHeadline(size: 18);
  static TextStyle get bodyLarge => arabicBody(size: 16);
  static TextStyle get body => arabicBody(size: 15);
  static TextStyle get bodySmall => arabicBody(size: 14);
  static TextStyle get caption => arabicCaption();
  static TextStyle get tiny => arabicCaption(size: 11);

  static TextStyle get buttonText => TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get whiteHeadline => arabicHeadline(
        color: Colors.white,
        size: 22,
      );

  static TextStyle get whitebody => arabicBody(
        color: Colors.white.withOpacity(0.9),
      );
}
