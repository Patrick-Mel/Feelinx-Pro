import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_text_field.dart';
import '../../../../core/network/dio_client.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();

  String _gender = 'female';
  String _intention = 'serious';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, String>> _intentions = [
    {'value': 'serious', 'label': '💍 Relation sérieuse'},
    {'value': 'friendship', 'label': '👋 Se faire des amis'},
    {'value': 'casual', 'label': '☕ Sorties & Discuter'},
    {'value': 'marriage', 'label': '💒 Mariage / Foyer'},
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
          _cityController.text = data['city'] ?? 'Douala';
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
        const SnackBar(content: Text("Prénom obligatoire.")),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final dio = DioClient().dio;
      final res = await dio.patch('profiles/me/', data: {
        'first_name': _firstNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'city': _cityController.text.trim(),
        'gender': _gender,
        'intention': _intention,
      });

      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour avec succès ! ✨"),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier mon profil", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxTextField(
                      label: "Prénom",
                      hint: "Ton prénom",
                      controller: _firstNameController,
                    ),
                    const SizedBox(height: 16),

                    Text("Genre", style: FxTypography.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("Femme")),
                            selected: _gender == 'female',
                            selectedColor: FxColors.primaryCoral,
                            onSelected: (_) => setState(() => _gender = 'female'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("Homme")),
                            selected: _gender == 'male',
                            selectedColor: FxColors.primaryCoral,
                            onSelected: (_) => setState(() => _gender = 'male'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    FxTextField(
                      label: "Ville",
                      hint: "Douala, Yaoundé...",
                      controller: _cityController,
                    ),
                    const SizedBox(height: 16),

                    Text("Bio / À propos de toi", style: FxTypography.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Dis-nous en plus sur toi, tes passions...",
                        filled: true,
                        fillColor: FxColors.darkCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text("Intention de recherche", style: FxTypography.titleMedium),
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
                          onSelected: (_) => setState(() => _intention = item['value']!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    FxButton(
                      text: "Enregistrer les modifications",
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
