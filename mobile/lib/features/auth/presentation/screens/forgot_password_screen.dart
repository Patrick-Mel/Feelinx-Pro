import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_phone_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String _selectedCountryCode = "+237";

  int _step = 1; // 1: enter phone, 2: enter code & new password
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _requestResetCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = "Veuillez entrer votre numéro de téléphone.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhone = "$_selectedCountryCode$phone";

    try {
      final dio = DioClient().dio;
      final res = await dio.post('auth/request-otp/', data: {'phone_number': fullPhone});

      if (res.statusCode == 200 && mounted) {
        setState(() {
          _step = 2;
          _successMessage = "Un code de vérification SMS a été envoyé au $fullPhone.";
        });
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      setState(() => _errorMessage = serverMsg is String ? serverMsg : "Numéro introuvable ou erreur de réseau.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmResetPassword() async {
    final phone = "$_selectedCountryCode${_phoneController.text.trim()}";
    final code = _otpController.text.trim();
    final newPassword = _newPasswordController.text;

    if (code.length != 6) {
      setState(() => _errorMessage = "Le code doit contenir 6 chiffres.");
      return;
    }

    if (newPassword.length < 6) {
      setState(() => _errorMessage = "Le mot de passe doit contenir au moins 6 caractères.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = DioClient().dio;
      final res = await dio.post('auth/reset-password/confirm/', data: {
        'phone_number': phone,
        'code': code,
        'new_password': newPassword,
      });

      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mot de passe réinitialisé avec succès ! Connectez-vous."),
            backgroundColor: FxColors.success,
          ),
        );
        context.go('/auth/login');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      setState(() => _errorMessage = serverMsg is String ? serverMsg : "Code incorrect ou expiré.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () {
            if (_step == 2) {
              setState(() => _step = 1);
            } else {
              context.go('/onboarding');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: FxSpacing.xxl24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: FxSpacing.md12),
              Text(
                _step == 1 ? "Mot de passe oublié" : "Nouveau mot de passe",
                style: FxTypography.displayMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FxSpacing.sm8),
              Text(
                _step == 1
                    ? "Entrez votre numéro pour recevoir un code de réinitialisation."
                    : "Saisissez le code SMS reçu ainsi que votre nouveau mot de passe.",
                style: FxTypography.bodyMedium.copyWith(color: textSecondary),
              ),
              const SizedBox(height: FxSpacing.xxxl32),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(FxSpacing.md12),
                  decoration: BoxDecoration(
                    color: FxColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(FxRadius.medium16),
                    border: Border.all(color: FxColors.error.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: FxColors.error, size: 20),
                      const SizedBox(width: FxSpacing.sm8),
                      Expanded(
                        child: Text(_errorMessage!, style: FxTypography.bodyMedium.copyWith(color: FxColors.error)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FxSpacing.lg16),
              ],

              if (_successMessage != null && _step == 2) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(FxSpacing.md12),
                  decoration: BoxDecoration(
                    color: FxColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(FxRadius.medium16),
                    border: Border.all(color: FxColors.success.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: FxColors.success, size: 20),
                      const SizedBox(width: FxSpacing.sm8),
                      Expanded(
                        child: Text(_successMessage!, style: FxTypography.bodyMedium.copyWith(color: FxColors.success)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FxSpacing.lg16),
              ],

              if (_step == 1) ...[
                FxPhoneField(
                  controller: _phoneController,
                  countryCode: _selectedCountryCode,
                  onCountryChanged: (code) => setState(() => _selectedCountryCode = code),
                ),
                const SizedBox(height: FxSpacing.xxl24),
                FxButton(
                  text: "Envoyer le code SMS",
                  isLoading: _isLoading,
                  onPressed: _requestResetCode,
                ),
              ] else ...[
                Text("Code de vérification SMS (6 chiffres)", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: FxSpacing.sm8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: "123456",
                    hintStyle: TextStyle(color: textSecondary),
                  ),
                ),
                const SizedBox(height: FxSpacing.xl20),
                Text("Nouveau mot de passe", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: FxSpacing.sm8),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _isPasswordObscured,
                  style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: "Au moins 6 caractères",
                    hintStyle: TextStyle(color: textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: textSecondary,
                      ),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                  ),
                ),
                const SizedBox(height: FxSpacing.xxl24),
                FxButton(
                  text: "Réinitialiser mon mot de passe",
                  isLoading: _isLoading,
                  onPressed: _confirmResetPassword,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
