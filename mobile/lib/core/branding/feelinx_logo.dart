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
            colors: [Color(0xFFFF4E64), Color(0xFF6C4AB6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
          break;
        case FeelinxColorMode.solid:
          paint.color = FxColors.primaryCoral;
          break;
        case FeelinxColorMode.monochromeBlack:
          paint.color = Colors.black;
          break;
        case FeelinxColorMode.white:
          paint.color = Colors.white;
          break;
        case FeelinxColorMode.gold:
          paint.shader = const LinearGradient(
            colors: [Color(0xFFFFE082), Color(0xFFF4B740), Color(0xFFB37D14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
          break;
      }
    }

    // Path 1: Primary Vertical Pillar & Top Curve (Left Entity)
    final Path path1 = Path();
    path1.moveTo(116 * scaleX, 420 * scaleY);
    path1.lineTo(116 * scaleX, 152 * scaleY);
    path1.cubicTo(116 * scaleX, 108 * scaleY, 152 * scaleX, 72 * scaleY, 196 * scaleX, 72 * scaleY);
    path1.lineTo(380 * scaleX, 72 * scaleY);
    path1.cubicTo(397.67 * scaleX, 72 * scaleY, 412 * scaleX, 86.33 * scaleY, 412 * scaleX, 104 * scaleY);
    path1.cubicTo(412 * scaleX, 121.67 * scaleY, 397.67 * scaleX, 136 * scaleY, 380 * scaleX, 136 * scaleY);
    path1.lineTo(216 * scaleX, 136 * scaleY);
    path1.cubicTo(196.12 * scaleX, 136 * scaleY, 180 * scaleX, 152.12 * scaleY, 180 * scaleX, 172 * scaleY);
    path1.lineTo(180 * scaleX, 420 * scaleY);
    path1.cubicTo(180 * scaleX, 437.67 * scaleY, 165.67 * scaleX, 452 * scaleY, 148 * scaleX, 452 * scaleY);
    path1.cubicTo(130.33 * scaleX, 452 * scaleY, 116 * scaleX, 437.67 * scaleY, 116 * scaleX, 420 * scaleY);
    path1.close();

    // Path 2: Interlocking Middle Arc (Right Entity / Link Connection)
    final Path path2 = Path();
    path2.moveTo(180 * scaleX, 248 * scaleY);
    path2.lineTo(340 * scaleX, 248 * scaleY);
    path2.cubicTo(362.09 * scaleX, 248 * scaleY, 380 * scaleX, 265.91 * scaleY, 380 * scaleX, 288 * scaleY);
    path2.cubicTo(380 * scaleX, 310.09 * scaleY, 362.09 * scaleX, 328 * scaleY, 340 * scaleX, 328 * scaleY);
    path2.lineTo(260 * scaleX, 328 * scaleY);
    path2.cubicTo(242.33 * scaleX, 328 * scaleY, 228 * scaleX, 342.33 * scaleY, 228 * scaleX, 360 * scaleY);
    path2.cubicTo(228 * scaleX, 377.67 * scaleY, 242.33 * scaleX, 392 * scaleY, 260 * scaleX, 392 * scaleY);
    path2.lineTo(340 * scaleX, 392 * scaleY);
    path2.cubicTo(397.44 * scaleX, 392 * scaleY, 444 * scaleX, 345.44 * scaleY, 444 * scaleX, 288 * scaleY);
    path2.cubicTo(444 * scaleX, 230.56 * scaleY, 397.44 * scaleX, 184 * scaleY, 340 * scaleX, 184 * scaleY);
    path2.lineTo(180 * scaleX, 184 * scaleY);
    path2.close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant FeelinxSymbolPainter oldDelegate) {
    return oldDelegate.colorMode != colorMode || oldDelegate.overrideColor != overrideColor;
  }
}
