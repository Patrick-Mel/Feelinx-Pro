import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_text_field.dart';
import '../../../../core/widgets/fx_city_picker.dart';
import '../../../../core/network/dio_client.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedCity = 'Douala (Cameroun)';
  String _gender = 'female';
  String _intention = 'serious';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, String>> _intentions = const [
    {'value': 'serious', 'label': 'Relation sérieuse'},
    {'value': 'friendship', 'label': 'Rencontres amicales'},
    {'value': 'casual', 'label': 'Sorties & Discussions'},
    {'value': 'marriage', 'label': 'Mariage & Foyer'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('profiles/me/');
      if (res.statusCode == 200 && mounted) {
        final data = res.data;
        setState(() {
          _firstNameController.text = data['first_name'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _selectedCity = data['city'] ?? 'Douala (Cameroun)';
          _gender = data['gender'] ?? 'female';
          _intention = data['intention'] ?? 'serious';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le prénom est obligatoire.")),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final dio = DioClient().dio;
      final res = await dio.patch('profiles/me/', data: {
        'first_name': _firstNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'city': _selectedCity,
        'gender': _gender,
        'intention': _intention,
      });

      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour avec succès."),
            backgroundColor: FxColors.success,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de la sauvegarde du profil."),
            backgroundColor: FxColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final cardBg = isDark ? FxColors.darkCard : FxColors.lightCard;
    final borderBg = isDark ? FxColors.darkBorder : FxColors.lightBorder;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Modifier mon profil", style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: FxColors.primaryCoral))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dedicated Photo Management Action Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderBg),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Gestion des photos de profil",
                                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Ajoute jusqu'à 9 photos et définis ta photo principale.",
                                    style: TextStyle(color: textSecondary, fontSize: 12),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            side: const BorderSide(color: FxColors.primaryCoral),
                                          ),
                                          icon: const Icon(Icons.add_a_photo_rounded, color: FxColors.primaryCoral, size: 18),
                                          label: const Text(
                                            "Définir photo de profil",
                                            style: TextStyle(color: FxColors.primaryCoral, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () => context.push('/profile/photos'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: FxColors.primaryCoral,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 18),
                                          label: const Text(
                                            "Mes 9 photos",
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () => context.push('/profile/photos'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            FxTextField(
                              label: "Prénom",
                              hint: "Ton prénom",
                              controller: _firstNameController,
                            ),
                            const SizedBox(height: 20),

                            Text("Je suis...", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(child: Text("Une femme")),
                                    selected: _gender == 'female',
                                    selectedColor: FxColors.primaryCoral,
                                    labelStyle: TextStyle(
                                      color: _gender == 'female' ? Colors.white : textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onSelected: (_) => setState(() => _gender = 'female'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(child: Text("Un homme")),
                                    selected: _gender == 'male',
                                    selectedColor: FxColors.primaryCoral,
                                    labelStyle: TextStyle(
                                      color: _gender == 'male' ? Colors.white : textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onSelected: (_) => setState(() => _gender = 'male'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            FxCityPickerTile(
                              selectedCity: _selectedCity,
                              onCitySelected: (city) => setState(() => _selectedCity = city),
                            ),
                            const SizedBox(height: 20),

                            Text("À propos de toi", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bioController,
                              maxLines: 4,
                              style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                              decoration: InputDecoration(
                                hintText: "Décris ta personnalité, tes passions et ce que tu recherches...",
                                hintStyle: TextStyle(color: textSecondary),
                                filled: true,
                                fillColor: cardBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderBg),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text("Intention de recherche", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _intentions.map((item) {
                                final isSelected = _intention == item['value'];
                                return ChoiceChip(
                                  label: Text(item['label']!),
                                  selected: isSelected,
                                  selectedColor: FxColors.primaryCoral,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (_) => setState(() => _intention = item['value']!),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Pinned Mobile Bottom Action Button
                    FxButton(
                      text: "ENREGISTRER LES MODIFICATIONS",
                      isLoading: _isSaving,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
