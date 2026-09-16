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
    return Scaffold(
      backgroundColor: FxColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Glowing Pulsing Aura
          AnimatedBuilder(
            animation: _auraPulse,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 320 * _auraPulse.value,
                  height: 320 * _auraPulse.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        FxColors.primaryCoral.withOpacity(0.35),
                        FxColors.secondaryIndigo.withOpacity(0.20),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // Central Animated Logo & Branding
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FeelinxLogoAnimated(
                  size: 130.0,
                ),
                const SizedBox(height: 16),
                Text(
                  "DES LIENS QUI SE RESSENTENT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.8,
                    color: Colors.white.withOpacity(0.7),
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
