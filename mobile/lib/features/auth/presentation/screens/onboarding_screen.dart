import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/branding/feelinx_logo.dart';
import '../../../../core/widgets/fx_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;
  Timer? _carouselTimer;

  final List<Map<String, String>> _heroSlides = const [
    {
      "image": "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=1200&q=80",
      "title": "Rencontres Authentiques",
      "subtitle": "Connecte-toi avec des personnes d'exception au Cameroun et en Afrique.",
    },
    {
      "image": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=1200&q=80",
      "title": "Des Liens Électrisants",
      "subtitle": "Un algorithme intelligent basé sur tes affinités et valeurs profondes.",
    },
    {
      "image": "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=1200&q=80",
      "title": "Profils Vérifiés & Sécurisés",
      "subtitle": "Échange en toute sérénité au sein d'une communauté sélect.",
    },
    {
      "image": "https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&w=1200&q=80",
      "title": "Émotions & Passion",
      "subtitle": "Des conversations vraies avec des personnes qui partagent ta vision.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int next = (_currentSlide + 1) % _heroSlides.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openLoginOptionsModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceBg = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final borderBg = isDark ? FxColors.darkBorder : FxColors.lightBorder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 20),
              Text(
                "Connexion à Feelinx",
                style: FxTypography.displayMedium.copyWith(
                  color: textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Choisissez votre méthode de connexion préférée.",
                style: FxTypography.bodyMedium.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 28),

              // Option 1: Connexion avec mot de passe
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/auth/login');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? FxColors.darkCard : FxColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderBg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FxColors.primaryCoral.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_outline, color: FxColors.primaryCoral, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Se connecter avec un mot de passe",
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Connexion classique avec votre numéro et mot de passe",
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Connexion avec le numéro (SMS OTP)
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/auth/phone');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? FxColors.darkCard : FxColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderBg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FxColors.secondaryIndigo.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_iphone, color: FxColors.secondaryIndigo, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Se connecter avec le numéro",
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Recevez un code de confirmation instantané par SMS",
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Problèmes de connexion link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/auth/forgot-password');
                  },
                  child: Text(
                    "Problèmes de connexion ?",
                    style: TextStyle(
                      color: FxColors.primaryCoral,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FxColors.darkBackground,
      body: Stack(
        children: [
          // Background Hero Carousel
          PageView.builder(
            controller: _pageController,
            itemCount: _heroSlides.length,
            onPageChanged: (idx) => setState(() => _currentSlide = idx),
            itemBuilder: (context, index) {
              final slide = _heroSlides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: FxColors.darkBackground),
                  Image.network(
                    slide["image"]!,
                    fit: BoxFit.cover,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 400),
                        child: child,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.2,
                            colors: [
                              FxColors.secondaryIndigo.withOpacity(0.2),
                              FxColors.darkBackground,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Dark Vignette Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          FxColors.darkBackground.withOpacity(0.35),
                          FxColors.darkBackground.withOpacity(0.65),
                          FxColors.darkBackground.withOpacity(0.98),
                        ],
                        stops: const [0.0, 0.45, 0.82],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Content Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: FxSpacing.xxl24, vertical: FxSpacing.lg16),
              child: Column(
                children: [
                  // Top Brand Header
                  const SizedBox(height: FxSpacing.md12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FeelinxLogo(size: 38, variant: FeelinxLogoVariant.symbol),
                      SizedBox(width: FxSpacing.sm8),
                      Text(
                        "Feelinx",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Carousel Text Content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey<int>(_currentSlide),
                      children: [
                        Text(
                          _heroSlides[_currentSlide]["title"]!,
                          textAlign: TextAlign.center,
                          style: FxTypography.displayMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: FxSpacing.md12),
                        Text(
                          _heroSlides[_currentSlide]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: FxTypography.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: FxSpacing.xxl24),

                  // Carousel Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _heroSlides.length,
                      (idx) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentSlide == idx ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentSlide == idx ? FxColors.primaryCoral : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: FxSpacing.xxxl32),

                  // Action Buttons (Only 2 Main Buttons)
                  FxButton(
                    text: "CRÉER UN COMPTE",
                    onPressed: () => context.go('/auth/register'),
                  ),
                  const SizedBox(height: 12),
                  FxButton(
                    text: "SE CONNECTER",
                    variant: FxButtonVariant.outline,
                    onPressed: () => _openLoginOptionsModal(context),
                  ),
                  const SizedBox(height: 20),

                  // Exact Disclaimer Text Requested
                  Text(
                    "En appuyant sur connexion ou Inscription, vous acceptez nos conditions. Découvrez comment nous traitons vos données dans notre politique de confidentialité et notre politique de cookies.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.68),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: FxSpacing.sm8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
