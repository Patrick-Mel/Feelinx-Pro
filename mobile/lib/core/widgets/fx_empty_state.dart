import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class FxEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const FxEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FxSpacing.xxl24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: FxSpacing.lg16),
            Text(title, style: FxTypography.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: FxSpacing.sm8),
            Text(
              description,
              style: FxTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: FxSpacing.xxl24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
