import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

enum FxButtonVariant { primary, secondary, outline, text, danger }

class FxButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final FxButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const FxButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = FxButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case FxButtonVariant.primary:
        bg = FxColors.primaryCoral;
        fg = Colors.white;
        break;
      case FxButtonVariant.secondary:
        bg = FxColors.secondaryIndigo;
        fg = Colors.white;
        break;
      case FxButtonVariant.outline:
        bg = Colors.transparent;
        fg = Theme.of(context).colorScheme.onSurface;
        border = BorderSide(color: FxColors.primaryCoral, width: 1.5);
        break;
      case FxButtonVariant.text:
        bg = Colors.transparent;
        fg = FxColors.primaryCoral;
        break;
      case FxButtonVariant.danger:
        bg = FxColors.error;
        fg = Colors.white;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: const StadiumBorder(),
          side: border,
          padding: const EdgeInsets.symmetric(horizontal: FxSpacing.xxl24),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: FxSpacing.sm8),
                  ],
                  Text(text, style: FxTypography.titleMedium.copyWith(color: fg)),
                ],
              ),
      ),
    );
  }
}
