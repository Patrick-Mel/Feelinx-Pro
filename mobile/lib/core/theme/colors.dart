import 'package:flutter/material.dart';

class FxColors {
  // Official Tinder Signature Palette
  static const Color tinderPink = Color(0xFFFD267D);
  static const Color tinderOrange = Color(0xFFFF6036);
  static const LinearGradient tinderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFD267D), Color(0xFFFF6036)],
  );

  // Brand Intentions
  static const Color primaryCoral = Color(0xFFFD267D);
  static const Color primaryCoralDark = Color(0xFFE03E53);
  static const Color secondaryIndigo = Color(0xFFFF6036);
  static const Color accentGold = Color(0xFFFFB300);

  // Semantics
  static const Color success = Color(0xFF11E3A2);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF4458);
  static const Color info = Color(0xFF00B0FF);

  // Tinder Action Colors
  static const Color likeGreen = Color(0xFF11E3A2);
  static const Color nopeRed = Color(0xFFFF4458);
  static const Color superlikeBlue = Color(0xFF00B0FF);
  static const Color rewindYellow = Color(0xFFFFB300);
  static const Color boostPurple = Color(0xFFA742F5);

  // Dark Neutral Palette (Tinder Dark Mode)
  static const Color darkBackground = Color(0xFF111419);
  static const Color darkSurface = Color(0xFF181C22);
  static const Color darkCard = Color(0xFF21262E);
  static const Color darkBorder = Color(0xFF2C323B);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9096A2);

  // Light Neutral Palette (Tinder Light Mode)
  static const Color lightBackground = Color(0xFFF0F2F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E4E9);
  static const Color lightTextPrimary = Color(0xFF21262E);
  static const Color lightTextSecondary = Color(0xFF707784);
}
