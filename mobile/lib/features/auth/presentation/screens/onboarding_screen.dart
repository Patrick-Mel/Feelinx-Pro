import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: "Rencontres Authentiques",
      description: "Découvre des personnes vraies et vérifiées près de chez toi au Cameroun et en Afrique.",
      icon: Icons.favorite,
    ),
    OnboardingSlide(
      title: "Amitié, Amour ou Réseau",
      description: "Choisis ton intention et laisse notre algorithme te proposer les profils les plus compatibles.",
      icon: Icons.people_alt,
    ),
    OnboardingSlide(
      title: "Communauté Sûre",
      description: "Profils vérifiés par selfie et sécurité renforcée contre les fausses identités.",
      icon: Icons.verified_user,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.xxl24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/auth/phone'),
                  child: const Text("Passer", style: TextStyle(color: FxColors.darkTextSecondary)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (idx) => setState(() => _currentIndex = idx),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: FxColors.primaryCoral.withOpacity(0.12),
                          ),
                          child: Icon(slide.icon, size: 72, color: FxColors.primaryCoral),
                        ),
                        const SizedBox(height: FxSpacing.xxxl32),
                        Text(slide.title, style: FxTypography.displayMedium, textAlign: TextAlign.center),
                        const SizedBox(height: FxSpacing.lg16),
                        Text(
                          slide.description,
                          style: FxTypography.bodyLarge.copyWith(color: FxColors.darkTextSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (idx) => AnimatedContainer(
                    duration: FxDurations.standard250,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == idx ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == idx ? FxColors.primaryCoral : FxColors.darkBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FxSpacing.xxxl32),
              FxButton(
                text: _currentIndex == _slides.length - 1 ? "Commencer" : "Suivant",
                onPressed: () {
                  if (_currentIndex < _slides.length - 1) {
                    _pageController.nextPage(duration: FxDurations.standard250, curve: FxCurves.defaultCurve);
                  } else {
                    context.go('/auth/phone');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
