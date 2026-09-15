import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class CountryInfo {
  final String name;
  final String code;
  const CountryInfo(this.name, this.code);
}

const List<CountryInfo> africanCountries = [
  CountryInfo("Cameroun", "+237"),
  CountryInfo("Côte d'Ivoire", "+225"),
  CountryInfo("Sénégal", "+221"),
  CountryInfo("Gabon", "+241"),
  CountryInfo("Congo", "+242"),
  CountryInfo("RDC", "+243"),
  CountryInfo("Togo", "+228"),
  CountryInfo("Bénin", "+229"),
  CountryInfo("Burkina Faso", "+226"),
  CountryInfo("Mali", "+223"),
  CountryInfo("Niger", "+227"),
  CountryInfo("Tchad", "+235"),
  CountryInfo("RCA", "+236"),
  CountryInfo("Rwanda", "+250"),
  CountryInfo("Burundi", "+257"),
  CountryInfo("Guinée Eq.", "+240"),
  CountryInfo("Maroc", "+212"),
  CountryInfo("Algérie", "+213"),
  CountryInfo("Tunisie", "+216"),
  CountryInfo("Nigeria", "+234"),
  CountryInfo("Ghana", "+233"),
  CountryInfo("Kenya", "+254"),
];

class FxPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String countryCode;
  final ValueChanged<String>? onCountryChanged;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const FxPhoneField({
    super.key,
    required this.controller,
    this.countryCode = "+237",
    this.onCountryChanged,
    this.onChanged,
    this.errorText,
  });

  void _selectCountry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FxColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sélectionner un pays", style: FxTypography.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: africanCountries.length,
                itemBuilder: (context, index) {
                  final c = africanCountries[index];
                  final isSelected = c.code == countryCode;
                  return ListTile(
                    title: Text(c.name, style: FxTypography.bodyLarge),
                    trailing: Text(
                      c.code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? FxColors.primaryCoral : FxColors.darkTextSecondary,
                      ),
                    ),
                    onTap: () {
                      if (onCountryChanged != null) onCountryChanged!(c.code);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => _selectCountry(context),
              borderRadius: BorderRadius.circular(FxRadius.medium16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(FxRadius.medium16),
                  border: Border.all(color: FxColors.darkBorder),
                ),
                child: Row(
                  children: [
                    Text(countryCode, style: FxTypography.titleMedium),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: FxColors.darkTextSecondary),
                  ],
                ),
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
