import 'package:flutter/material.dart';

/// Central palette for the app.
///
/// Every colour lives here so the product can be re-skinned from a single
/// file and feature code never hard-codes a hex value.
abstract final class AppColors {
  // ------------------------------------------------------------------ brand
  static const Color brand = Color(0xFF6C4DF6);
  static const Color brandSoft = Color(0xFFEDE8FF);

  // --------------------------------------------------------------- surfaces
  static const Color lightBackground = Color(0xFFF6F5FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF1EFFA);
  static const Color lightOnSurface = Color(0xFF16142A);
  static const Color lightOnSurfaceMuted = Color(0xFF6E6A85);

  static const Color darkBackground = Color(0xFF0E0D17);
  static const Color darkSurface = Color(0xFF171625);
  static const Color darkSurfaceMuted = Color(0xFF211F33);
  static const Color darkOnSurface = Color(0xFFF3F2FA);
  static const Color darkOnSurfaceMuted = Color(0xFF9B96B5);

  // --------------------------------------------------------- module accents
  static const Color habits = Color(0xFF6C4DF6);
  static const Color habitsAlt = Color(0xFFA78BFA);
  static const Color mood = Color(0xFFF59E0B);
  static const Color moodAlt = Color(0xFFFBBF24);
  static const Color focus = Color(0xFF0EA5E9);
  static const Color focusAlt = Color(0xFF38BDF8);
  static const Color expenses = Color(0xFF10B981);
  static const Color expensesAlt = Color(0xFF34D399);
  static const Color diary = Color(0xFFF43F5E);
  static const Color diaryAlt = Color(0xFFFB7185);

  // ----------------------------------------------------------------- status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}
