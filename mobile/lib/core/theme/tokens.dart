import 'package:flutter/material.dart';

class FxSpacing {
  static const double xs4 = 4.0;
  static const double sm8 = 8.0;
  static const double md12 = 12.0;
  static const double lg16 = 16.0;
  static const double xl20 = 20.0;
  static const double xxl24 = 24.0;
  static const double xxxl32 = 32.0;
  static const double huge48 = 48.0;
}

class FxRadius {
  static const double small8 = 8.0;
  static const double medium16 = 16.0;
  static const double large24 = 24.0;
  static const double cardSwipe32 = 32.0;
}

class FxDurations {
  static const Duration fast150 = Duration(milliseconds: 150);
  static const Duration standard250 = Duration(milliseconds: 250);
  static const Duration emphasis400 = Duration(milliseconds: 400);
  static const Duration celebration600 = Duration(milliseconds: 600);
}

class FxCurves {
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve playfulBounce = Curves.easeOutBack;
  static const Curve springLike = Curves.elasticOut;
}

class FxShadows {
  static List<BoxShadow> softShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: color.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.35),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];
}
