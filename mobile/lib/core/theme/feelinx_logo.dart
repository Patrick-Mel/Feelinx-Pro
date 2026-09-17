import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum FeelinxLogoVariant {
  symbol,
  fullHorizontal,
  vertical,
  wordmark,
}

enum FeelinxColorMode {
  gradient,
  solid,
  monochromeBlack,
  white,
  gold,
}

typedef LogoVariant = FeelinxLogoVariant;
typedef LogoColorMode = FeelinxColorMode;

class FeelinxLogo extends StatelessWidget {
  final double size;
  final FeelinxLogoVariant variant;
  final FeelinxColorMode colorMode;
  final Color? overrideColor;

  const FeelinxLogo({
    super.key,
    this.size = 48.0,
    this.variant = FeelinxLogoVariant.fullHorizontal,
    this.colorMode = FeelinxColorMode.gradient,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case FeelinxLogoVariant.symbol:
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            size: Size(size, size),
            painter: FeelinxSymbolPainter(colorMode: colorMode, overrideColor: overrideColor),
          ),
        );

      case FeelinxLogoVariant.wordmark:
        final textColor = overrideColor ?? (colorMode == FeelinxColorMode.white
            ? Colors.white
            : (colorMode == FeelinxColorMode.monochromeBlack
                ? Colors.black
                : Theme.of(context).colorScheme.onSurface));

        if (colorMode == FeelinxColorMode.gradient) {
          return ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [FxColors.primaryCoral, FxColors.secondaryIndigo, FxColors.accentGold],
            ).createShader(bounds),
            child: Text(
              "Feelinx",
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
                color: Colors.white,
              ),
            ),
          );
        }

        return Text(
          "Feelinx",
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
            color: textColor,
          ),
        );

      case FeelinxLogoVariant.vertical:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FeelinxLogo(size: size * 0.7, variant: FeelinxLogoVariant.symbol, colorMode: colorMode, overrideColor: overrideColor),
            SizedBox(height: size * 0.15),
            FeelinxLogo(size: size * 0.4, variant: FeelinxLogoVariant.wordmark, colorMode: colorMode, overrideColor: overrideColor),
          ],
        );

      case FeelinxLogoVariant.fullHorizontal:
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FeelinxLogo(size: size, variant: FeelinxLogoVariant.symbol, colorMode: colorMode, overrideColor: overrideColor),
            SizedBox(width: size * 0.25),
            FeelinxLogo(size: size * 0.7, variant: FeelinxLogoVariant.wordmark, colorMode: colorMode, overrideColor: overrideColor),
          ],
        );
    }
  }
}

class FeelinxSymbolPainter extends CustomPainter {
  final FeelinxColorMode colorMode;
  final Color? overrideColor;

  FeelinxSymbolPainter({
    required this.colorMode,
    this.overrideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Paint configuration
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round;

    if (overrideColor != null) {
      paint.color = overrideColor!;
    } else {
      switch (colorMode) {
        case FeelinxColorMode.gradient:
          paint.shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FxColors.primaryCoral, FxColors.secondaryIndigo, FxColors.accentGold],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
          break;
        case FeelinxColorMode.white:
          paint.color = Colors.white;
          break;
        case FeelinxColorMode.monochromeBlack:
          paint.color = FxColors.darkBackground;
          break;
        case FeelinxColorMode.gold:
          paint.color = FxColors.accentGold;
          break;
        case FeelinxColorMode.solid:
        default:
          paint.color = FxColors.primaryCoral;
          break;
      }
    }

    // Outer Glow Circle (Subtle)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..color = FxColors.primaryCoral.withOpacity(0.2);
    canvas.drawCircle(center, radius, glowPaint);

    // Left Ring Offset (Coral Entity)
    final leftCenter = Offset(center.dx - size.width * 0.08, center.dy);
    canvas.drawCircle(leftCenter, radius * 0.55, paint);

    // Right Ring Offset (Indigo/Violet Entity)
    final rightCenter = Offset(center.dx + size.width * 0.08, center.dy);
    canvas.drawCircle(rightCenter, radius * 0.55, paint);

    // Spark Core Dot
    final sparkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = overrideColor ?? FxColors.accentGold;
    canvas.drawCircle(center, size.width * 0.08, sparkPaint);

    final innerCorePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(center, size.width * 0.035, innerCorePaint);
  }

  @override
  bool shouldRepaint(covariant FeelinxSymbolPainter oldDelegate) {
    return oldDelegate.colorMode != colorMode || oldDelegate.overrideColor != overrideColor;
  }
}
