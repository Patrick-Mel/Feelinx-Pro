import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/branding/feelinx_logo_animated.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Guarantee maximum splash duration of 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
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
        } catch (_) {
          // On network error or invalid token, proceed to onboarding
        }
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
    return const Scaffold(
      backgroundColor: Color(0xFF0A0915),
      body: Center(
        child: FeelinxLogoAnimated(
          size: 110.0,
        ),
      ),
    );
  }
}
