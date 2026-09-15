import 'package:flutter/material.dart';
import '../constants/african_cities.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class FxCityPickerTile extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;

  const FxCityPickerTile({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
  });

  void _openCityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FxColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CitySearchSheet(
        selectedCity: selectedCity,
        onCitySelected: (city) {
          onCitySelected(city);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ville d'Afrique", style: FxTypography.titleMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _openCityModal(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: FxColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FxColors.darkBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_city, color: FxColors.primaryCoral, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCity.isEmpty ? "Sélectionner une ville" : selectedCity,
                    style: FxTypography.bodyLarge.copyWith(
                      color: selectedCity.isEmpty ? FxColors.darkTextSecondary : FxColors.darkTextPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: FxColors.darkTextSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CitySearchSheet extends StatefulWidget {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;

  const _CitySearchSheet({
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final _searchController = TextEditingController();
  List<String> _filteredCities = AfricanCities.allCities;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = AfricanCities.allCities;
      } else {
        _filteredCities = AfricanCities.allCities
            .where((c) => c.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FxColors.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Sélectionner ta ville", style: FxTypography.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                style: FxTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: "Rechercher une ville africaine...",
                  prefixIcon: const Icon(Icons.search, color: FxColors.primaryCoral),
                  filled: true,
                  fillColor: FxColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredCities.isEmpty
                    ? Center(
                        child: Text(
                          "Aucune ville trouvée",
                          style: FxTypography.bodyLarge.copyWith(color: FxColors.darkTextSecondary),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = _filteredCities[index];
                          final isSelected = city == widget.selectedCity;
                          return ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: isSelected ? FxColors.primaryCoral : FxColors.darkTextSecondary,
                            ),
                            title: Text(
                              city,
                              style: FxTypography.bodyLarge.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? FxColors.primaryCoral : FxColors.darkTextPrimary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: FxColors.primaryCoral)
                                : null,
                            onTap: () => widget.onCitySelected(city),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
