import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_text_field.dart';
import '../../../../core/widgets/fx_chip.dart';
import '../../../../core/widgets/fx_city_picker.dart';
import '../../../../core/network/dio_client.dart';

class RegistrationWizardScreen extends StatefulWidget {
  const RegistrationWizardScreen({super.key});

  @override
  State<RegistrationWizardScreen> createState() => _RegistrationWizardScreenState();
}

class _RegistrationWizardScreenState extends State<RegistrationWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 8;

  // Form values
  final TextEditingController _firstNameController = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'female';
  String _seeking = 'male';
  String _intention = 'serious';
  String _city = 'Douala (Cameroun)';
  final TextEditingController _bioController = TextEditingController();
  final Set<String> _selectedInterests = {};
  bool _isLoading = false;

  final List<Map<String, String>> _intentionsList = const [
    {"code": "serious", "label": "Relation sérieuse"},
    {"code": "casual", "label": "Sorties & Discussions"},
    {"code": "friendship", "label": "Rencontres amicales"},
    {"code": "networking", "label": "Réseautage professionnel"},
    {"code": "undecided", "label": "En cours de découverte"},
  ];

  final List<Map<String, String>> _interestsList = const [
    {"code": "afrobeats", "label": "Afrobeats & Musique"},
    {"code": "makossa", "label": "Makossa & Bikutsi"},
    {"code": "football", "label": "Football"},
    {"code": "ndole", "label": "Gastronomie Africaine"},
    {"code": "fashion", "label": "Mode & Style"},
    {"code": "tech", "label": "Tech & Innovation"},
    {"code": "travel", "label": "Voyages & Ecotourisme"},
    {"code": "gaming", "label": "Jeux Vidéo"},
    {"code": "church", "label": "Foi & Église"},
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: FxDurations.standard250, curve: FxCurves.defaultCurve);
      setState(() => _currentStep++);
    } else {
      _submitRegistration();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: FxDurations.standard250, curve: FxCurves.defaultCurve);
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;
      final name = _firstNameController.text.trim();
      await dio.patch('profiles/me/', data: {
        'first_name': name.isEmpty ? 'Membre' : name,
        'birth_date': _birthDate != null ? _birthDate!.toIso8601String().split('T')[0] : '2000-01-01',
        'gender': _gender,
        'seeking': _seeking,
        'intention': _intention,
        'city': _city,
        'bio': _bioController.text.trim(),
      });

      if (mounted) {
        context.go('/discovery');
      }
    } catch (e) {
      if (mounted) context.go('/discovery');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep)
            : null,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            minHeight: 6,
            backgroundColor: FxColors.darkBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(FxColors.primaryCoral),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.xxl24),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Step 1: Prénom
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Comment t'appelles-tu ?", style: FxTypography.displayMedium),
                        const SizedBox(height: FxSpacing.xxxl32),
                        FxTextField(
                          label: "Ton prénom",
                          hint: "ex. Manuella",
                          controller: _firstNameController,
                        ),
                      ],
                    ),
                    // Step 2: Date de naissance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quelle est ta date de naissance ?", style: FxTypography.displayMedium),
                        const SizedBox(height: FxSpacing.sm8),
                        Text("Seules les personnes majeures (18 ans et plus) peuvent s'inscrire.", style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary)),
                        const SizedBox(height: FxSpacing.xxxl32),
                        OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000, 1, 1),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2008, 1, 1),
                            );
                            if (picked != null) setState(() => _birthDate = picked);
                          },
                          child: Text(_birthDate == null ? "Sélectionner ma date" : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}"),
                        ),
                      ],
                    ),
                    // Step 3: Genre
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quel est ton genre ?", style: FxTypography.displayMedium),
                        const SizedBox(height: FxSpacing.xxxl32),
                        RadioListTile<String>(
                          title: const Text("Femme"),
                          value: 'female',
                          groupValue: _gender,
                          activeColor: FxColors.primaryCoral,
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                        RadioListTile<String>(
                          title: const Text("Homme"),
                          value: 'male',
                          groupValue: _gender,
                          activeColor: FxColors.primaryCoral,
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ],
                    ),
                    // Step 4: Recherche
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tu recherches...", style: FxTypography.displayMedium),
                        const SizedBox(height: FxSpacing.xxxl32),
                        RadioListTile<String>(
                          title: const Text("Des hommes"),
                          value: 'male',
                          groupValue: _seeking,
                          activeColor: FxColors.primaryCoral,
                          onChanged: (v) => setState(() => _seeking = v!),
                        ),
                        RadioListTile<String>(
                          title: const Text("Des femmes"),
                          value: 'female',
                          groupValue: _seeking,
                          activeColor: FxColors.primaryCoral,
                          onChanged: (v) => setState(() => _seeking = v!),
                        ),
                      ],
                    ),
                    // Step 5: Intention
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quelle est ton intention ?", style: FxTypography.displayMedium),
                        const SizedBox(height: FxSpacing.lg16),
                        ..._intentionsList.map((item) {
                          final isSelected = _intention == item["code"];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FxChip(
                              label: item["label"]!,
                              isSelected: isSelected,
                              onTap: () => setState(() => _intention = item["code"]!),
                            ),
                          );
                        }),
                      ],
                    ),
                    // Step 6: Ville Africaine
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dans quelle ville vis-tu ?", style: FxTypography.displayMedium),
                        const SizedBox(height: FxSpacing.sm8),
                        Text("Sélectionne ta ville parmi les métropoles africaines.", style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary)),
                        const SizedBox(height: FxSpacing.xxxl32),
                        FxCityPickerTile(
                          selectedCity: _city,
                          onCitySelected: (v) => setState(() => _city = v),
                        ),
                      ],
                    ),
                    // Step 7: Intérêts
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tes centres d'intérêt", style: FxTypography.displayMedium),
                        const SizedBox(height: FxSpacing.sm8),
                        Text("Choisis au moins 3 centres d'intérêt", style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary)),
                        const SizedBox(height: FxSpacing.lg16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interestsList.map((item) {
                            final isSel = _selectedInterests.contains(item["code"]);
                            return FxChip(
                              label: item["label"]!,
                              isSelected: isSel,
                              onTap: () {
                                setState(() {
                                  if (isSel) {
                                    _selectedInterests.remove(item["code"]);
                                  } else {
                                    _selectedInterests.add(item["code"]!);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Step 8: Bio
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Écris ta biographie", style: FxTypography.displayMedium),
                        const SizedBox(height: FxSpacing.xxxl32),
                        FxTextField(
                          label: "À propos de toi",
                          hint: "Parle de tes passions, de ce qui te caractérise...",
                          controller: _bioController,
                          maxLines: 4,
                          maxLength: 500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FxButton(
                text: _currentStep == _totalSteps - 1 ? "Finaliser mon profil" : "Continuer",
                isLoading: _isLoading,
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
