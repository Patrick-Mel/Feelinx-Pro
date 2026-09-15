import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

class FxShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const FxShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = FxRadius.medium16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? FxColors.darkSurface : FxColors.lightCard;
    final highlightColor = isDark ? FxColors.darkCard : FxColors.lightSurface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
