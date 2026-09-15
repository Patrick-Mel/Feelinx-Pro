import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_otp_input.dart';
import '../../../../core/network/dio_client.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = "";
  bool _isLoading = false;
  String? _errorMessage;
  int _timerSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timerSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    _startTimer();
    try {
      final dio = DioClient().dio;
      final res = await dio.post('auth/request-otp/', data: {'phone_number': widget.phoneNumber});
      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Un nouveau code de vérification a été envoyé."),
            backgroundColor: FxColors.info,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_code.length < 6) {
      setState(() => _errorMessage = "Veuillez saisir les 6 chiffres du code SMS.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = DioClient().dio;
      final res = await dio.post('auth/verify-otp/', data: {
        'phone_number': widget.phoneNumber,
        'code': _code,
      });

      if (res.statusCode == 200 && mounted) {
        final data = res.data;
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final isNewUser = data['is_new_user'] ?? false;
        final hasProfile = data['has_profile'] ?? false;

        const storage = FlutterSecureStorage();
        await storage.write(key: 'jwt_access_token', value: accessToken);
        await storage.write(key: 'jwt_refresh_token', value: refreshToken);

        if (isNewUser || !hasProfile) {
          context.go('/onboarding/wizard');
        } else {
          context.go('/discovery');
        }
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['message'] ?? "Code incorrect ou expiré. Veuillez réessayer.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth/phone'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.xxl24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vérification SMS", style: FxTypography.displayMedium),
              const SizedBox(height: FxSpacing.sm8),
              Text(
                "Saisissez le code à 6 chiffres envoyé au ${widget.phoneNumber}",
                style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary),
              ),
              const SizedBox(height: FxSpacing.xxxl32),
              FxOtpInput(
                onCompleted: (val) {
                  setState(() => _code = val);
                  _verifyOtp();
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: FxSpacing.lg16),
                Center(
                  child: Text(
                    _errorMessage!,
                    style: FxTypography.bodyMedium.copyWith(color: FxColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const Spacer(),
              Center(
                child: _timerSeconds > 0
                    ? Text(
                        "Renvoyer le code dans ${_timerSeconds}s",
                        style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: const Text("Renvoyer le code maintenant", style: TextStyle(color: FxColors.primaryCoral)),
                      ),
              ),
              const SizedBox(height: FxSpacing.lg16),
              FxButton(
                text: "Vérifier et continuer",
                isLoading: _isLoading,
                onPressed: _verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
