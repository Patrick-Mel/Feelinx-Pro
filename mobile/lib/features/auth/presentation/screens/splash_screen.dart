import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/branding/feelinx_logo_animated.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _auraController;
  late Animation<double> _auraPulse;

  @override
  void initState() {
    super.initState();
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _auraPulse = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _auraController, curve: Curves.easeInOut),
    );

    _checkAuth();
  }

  @override
  void dispose() {
    _auraController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_access_token').timeout(
        const Duration(seconds: 1),
        onTimeout: () => null,
      );

      if (token != null && token.isNotEmpty) {
        try {
          final dio = DioClient().dio;
          final res = await dio.get('profiles/me/').timeout(
            const Duration(seconds: 2),
          );
          if (res.statusCode == 200 && mounted) {
            final profile = res.data;
            final firstName = profile['first_name'];
            if (firstName != null && firstName.isNotEmpty && firstName != 'Membre') {
              context.go('/discovery');
              return;
            } else {
              context.go('/onboarding/wizard');
              return;
            }
          }
        } catch (_) {}
      }
    } catch (_) {
    } finally {
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Glowing Pulsing Aura Rings
          AnimatedBuilder(
            animation: _auraPulse,
            builder: (context, child) {
              final scale = _auraPulse.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ambient Glow Ring
                  Container(
                    width: 360 * scale,
                    height: 360 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          FxColors.primaryCoral.withOpacity(isDark ? 0.25 : 0.18),
                          FxColors.secondaryIndigo.withOpacity(isDark ? 0.15 : 0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  // Inner Vivid Glow Ring
                  Container(
                    width: 200 * (2.0 - scale),
                    height: 200 * (2.0 - scale),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          FxColors.tinderPink.withOpacity(isDark ? 0.35 : 0.22),
                          FxColors.accentGold.withOpacity(isDark ? 0.15 : 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Central Animated Logo & Grandiose Branding
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FeelinxLogoAnimated(
                  size: 140.0,
                ),
                const SizedBox(height: 24),
                Text(
                  "DES LIENS QUI SE RESSENTENT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.5,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
