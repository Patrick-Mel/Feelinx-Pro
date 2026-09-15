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
            painter: FeelinxSymbolPainter(colorMode: colorMode, overrideColor: overrideColor),
          ),
        );

      case FeelinxLogoVariant.wordmark:
        return _buildWordmark(context, size * 0.4);

      case FeelinxLogoVariant.fullHorizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: FeelinxSymbolPainter(colorMode: colorMode, overrideColor: overrideColor),
              ),
            ),
            SizedBox(width: size * 0.25),
            _buildWordmark(context, size * 0.65),
          ],
        );

      case FeelinxLogoVariant.vertical:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: FeelinxSymbolPainter(colorMode: colorMode, overrideColor: overrideColor),
              ),
            ),
            SizedBox(height: size * 0.2),
            _buildWordmark(context, size * 0.5),
            SizedBox(height: size * 0.08),
            Text(
              "DES LIENS QUI SE RESSENTENT",
              style: TextStyle(
                fontSize: size * 0.1,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: colorMode == FeelinxColorMode.monochromeBlack ? Colors.black54 : FxColors.darkTextSecondary,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildWordmark(BuildContext context, double fontSize) {
    final TextStyle baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
      fontFamily: 'Plus Jakarta Sans',
    );

    if (colorMode == FeelinxColorMode.monochromeBlack) {
      return Text("Feelinx", style: baseStyle.copyWith(color: Colors.black));
    }

    if (colorMode == FeelinxColorMode.white) {
      return Text("Feelinx", style: baseStyle.copyWith(color: Colors.white));
    }

    if (colorMode == FeelinxColorMode.gold) {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFF4B740), Color(0xFFB37D14)],
        ).createShader(bounds),
        child: Text("Feelinx", style: baseStyle.copyWith(color: Colors.white)),
      );
    }

    // Default Gradient
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: "Feel", style: baseStyle.copyWith(color: Colors.white)),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF4E64), Color(0xFF6C4AB6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text("inx", style: baseStyle.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
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
    final double scaleX = size.width / 512.0;
    final double scaleY = size.height / 512.0;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    if (overrideColor != null) {
      paint.color = overrideColor!;
    } else {
      switch (colorMode) {
        case FeelinxColorMode.gradient:
          paint.shader = const LinearGradient(
            colors: [Color(0xFFFF3366), Color(0xFF9D4EDD), Color(0xFF7B2CBF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
          break;
        case FeelinxColorMode.solid:
          paint.color = const Color(0xFFFF3366);
          break;
        case FeelinxColorMode.monochromeBlack:
          paint.color = Colors.black;
          break;
        case FeelinxColorMode.white:
          paint.color = Colors.white;
          break;
        case FeelinxColorMode.gold:
          paint.shader = const LinearGradient(
            colors: [Color(0xFFFFE082), Color(0xFFFFB703), Color(0xFFD48800)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
          break;
      }
    }

    // Path 1: Outer Arc & Pillar (Left Entity)
    final Path path1 = Path();
    path1.moveTo(140 * scaleX, 420 * scaleY);
    path1.lineTo(140 * scaleX, 160 * scaleY);
    path1.cubicTo(140 * scaleX, 110 * scaleY, 180 * scaleX, 70 * scaleY, 230 * scaleX, 70 * scaleY);
    path1.lineTo(380 * scaleX, 70 * scaleY);
    path1.cubicTo(402.09 * scaleX, 70 * scaleY, 420 * scaleX, 87.91 * scaleY, 420 * scaleX, 110 * scaleY);
    path1.cubicTo(420 * scaleX, 132.09 * scaleY, 402.09 * scaleX, 150 * scaleY, 380 * scaleX, 150 * scaleY);
    path1.lineTo(220 * scaleX, 150 * scaleY);
    path1.cubicTo(203.43 * scaleX, 150 * scaleY, 190 * scaleX, 163.43 * scaleY, 190 * scaleX, 180 * scaleY);
    path1.lineTo(190 * scaleX, 420 * scaleY);
    path1.cubicTo(190 * scaleX, 436.57 * scaleY, 176.57 * scaleX, 450 * scaleY, 160 * scaleX, 450 * scaleY);
    path1.cubicTo(143.43 * scaleX, 450 * scaleY, 140 * scaleX, 436.57 * scaleY, 140 * scaleX, 420 * scaleY);
    path1.close();

    // Path 2: Interlocking Heart Arc (Right Entity / Link Connection)
    final Path path2 = Path();
    path2.moveTo(190 * scaleX, 230 * scaleY);
    path2.lineTo(350 * scaleX, 230 * scaleY);
    path2.cubicTo(394.18 * scaleX, 230 * scaleY, 430 * scaleX, 265.82 * scaleY, 430 * scaleX, 310 * scaleY);
    path2.cubicTo(430 * scaleX, 354.18 * scaleY, 394.18 * scaleX, 390 * scaleY, 350 * scaleX, 390 * scaleY);
    path2.cubicTo(315 * scaleX, 390 * scaleY, 280 * scaleX, 360 * scaleY, 250 * scaleX, 325 * scaleY);
    path2.cubicTo(235 * scaleX, 307.5 * scaleY, 210 * scaleX, 307.5 * scaleY, 195 * scaleX, 325 * scaleY);
    path2.cubicTo(185 * scaleX, 336.6 * scaleY, 175 * scaleX, 348 * scaleY, 165 * scaleX, 358 * scaleY);
    path2.cubicTo(153.28 * scaleX, 369.72 * scaleY, 134.28 * scaleX, 369.72 * scaleY, 122.56 * scaleX, 358 * scaleY);
    path2.cubicTo(110.84 * scaleX, 346.28 * scaleY, 110.84 * scaleX, 327.28 * scaleY, 122.56 * scaleX, 315.56 * scaleY);
    path2.cubicTo(135 * scaleX, 303.12 * scaleY, 155 * scaleX, 280 * scaleY, 190 * scaleX, 230 * scaleY);
    path2.close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant FeelinxSymbolPainter oldDelegate) {
    return oldDelegate.colorMode != colorMode || oldDelegate.overrideColor != overrideColor;
  }
}
