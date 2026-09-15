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
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_access_token');

    if (token != null && token.isNotEmpty) {
      try {
        final dio = DioClient().dio;
        final res = await dio.get('profiles/me/');
        if (res.statusCode == 200 && mounted) {
          final profile = res.data;
          final firstName = profile['first_name'];
          if (firstName != null && firstName.isNotEmpty && firstName != 'Membre') {
            context.go('/discovery');
          } else {
            context.go('/onboarding/wizard');
          }
          return;
        }
      } catch (_) {
        await storage.deleteAll();
      }
    }

    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FeelinxLogoAnimated(
          size: 110.0,
        ),
      ),
    );
  }
}
