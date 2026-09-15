import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF4E64), Color(0xFF6C4AB6)],
                  ),
                ),
                child: const Center(
                  child: Text("F", style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Feelinx", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text("Des liens qui se ressentent", style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
}
