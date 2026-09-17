import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../utils/country_registry.dart';

class FxPhoneField extends StatefulWidget {
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

  @override
  State<FxPhoneField> createState() => _FxPhoneFieldState();
}

class _FxPhoneFieldState extends State<FxPhoneField> {
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.countryCode);
  }

  @override
  void didUpdateWidget(covariant FxPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryCode != widget.countryCode && _codeController.text != widget.countryCode) {
      _codeController.text = widget.countryCode;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _openCountryPickerModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceBg = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final borderBg = isDark ? FxColors.darkBorder : FxColors.lightBorder;

    final searchController = TextEditingController();
    List<CountryData> filtered = List.from(CountryRegistry.allCountries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterList(String query) {
              setModalState(() {
                final q = query.toLowerCase().trim();
                filtered = CountryRegistry.allCountries.where((c) {
                  return c.name.toLowerCase().contains(q) || c.code.contains(q);
                }).toList();
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderBg,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Sélectionnez votre pays", style: FxTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Search input
                  TextField(
                    controller: searchController,
                    onChanged: filterList,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: "Rechercher par pays ou indicatif (ex. +237, Cameroun)...",
                      hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text("Aucun pays correspondant.", style: TextStyle(color: textSecondary)),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => Divider(color: borderBg, height: 1),
                            itemBuilder: (context, index) {
                              final c = filtered[index];
                              final isSelected = c.code == _codeController.text.trim();

                              return ListTile(
                                title: Text(c.name, style: TextStyle(color: textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? FxColors.primaryCoral.withOpacity(0.15) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    c.code,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? FxColors.primaryCoral : textSecondary,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _codeController.text = c.code;
                                  });
                                  if (widget.onCountryChanged != null) {
                                    widget.onCountryChanged!(c.code);
                                  }
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;

    final detectedCountry = CountryRegistry.findByCode(_codeController.text);
    final isValid = detectedCountry != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Country Badge Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Numéro de téléphone", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isValid ? FxColors.primaryCoral.withOpacity(0.12) : FxColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isValid ? FxColors.primaryCoral.withOpacity(0.4) : FxColors.error.withOpacity(0.4)),
              ),
              child: Text(
                isValid ? detectedCountry.name : "Indicatif invalide",
                style: FxTypography.bodyMedium.copyWith(
                  color: isValid ? FxColors.primaryCoral : FxColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.sm8),

        Row(
          children: [
            // Code Input / Selector Box
            InkWell(
              onTap: () => _openCountryPickerModal(context),
              child: SizedBox(
                width: 100,
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    setState(() {});
                    final found = CountryRegistry.findByCode(val);
                    if (found != null && widget.onCountryChanged != null) {
                      widget.onCountryChanged!(found.code);
                    }
                  },
                  style: FxTypography.bodyLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: "+237",
                    hintStyle: TextStyle(color: textSecondary),
                    suffixIcon: Icon(Icons.arrow_drop_down, color: textSecondary, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: FxSpacing.sm8),

            // Main Phone Number Input
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                keyboardType: TextInputType.phone,
                style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                decoration: InputDecoration(
                  hintText: "690000000",
                  hintStyle: TextStyle(color: textSecondary),
                  errorText: widget.errorText,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
