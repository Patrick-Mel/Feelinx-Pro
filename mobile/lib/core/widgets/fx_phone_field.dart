import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class FxPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String countryCode;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const FxPhoneField({
    super.key,
    required this.controller,
    this.countryCode = "+237",
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(FxRadius.medium16),
                border: Border.all(color: FxColors.darkBorder),
              ),
              child: Row(
                children: [
                  const Text("🇨🇲", style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(countryCode, style: FxTypography.titleMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: TextInputType.phone,
                style: FxTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: "690 00 00 00",
                  errorText: errorText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
