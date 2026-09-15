import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_text_field.dart';

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

  final List<Map<String, String>> _countries = [
    {"code": "+237", "flag": "🇨🇲", "name": "Cameroun"},
    {"code": "+225", "flag": "🇨🇮", "name": "Côte d'Ivoire"},
    {"code": "+221", "flag": "🇸🇳", "name": "Sénégal"},
    {"code": "+242", "flag": "🇨🇬", "name": "Congo"},
    {"code": "+243", "flag": "🇨🇩", "name": "RDC"},
    {"code": "+33",  "flag": "🇫🇷", "name": "France"},
  ];

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
    return Scaffold(
      backgroundColor: FxColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {
            if (_step == 2) {
              setState(() => _step = 1);
            } else {
              context.go('/auth/login');
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
                style: FxTypography.displayMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FxSpacing.xs8),
              Text(
                _step == 1
                    ? "Entrez votre numéro pour recevoir un code de réinitialisation."
                    : "Saisissez le code SMS reçu ainsi que votre nouveau mot de passe.",
                style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary),
              ),
              const SizedBox(height: FxSpacing.xxxl32),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(FxSpacing.md12),
                  decoration: BoxDecoration(
                    color: FxColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(FxRadii.md12),
                    border: Border.all(color: FxColors.error.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: FxColors.error, size: 20),
                      const SizedBox(width: FxSpacing.sm10),
                      Expanded(
                        child: Text(_errorMessage!, style: FxTypography.bodySmall.copyWith(color: FxColors.error)),
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
                    borderRadius: BorderRadius.circular(FxRadii.md12),
                    border: Border.all(color: FxColors.success.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: FxColors.success, size: 20),
                      const SizedBox(width: FxSpacing.sm10),
                      Expanded(
                        child: Text(_successMessage!, style: FxTypography.bodySmall.copyWith(color: FxColors.success)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FxSpacing.lg16),
              ],

              if (_step == 1) ...[
                Text("Numéro de téléphone", style: FxTypography.labelLarge.copyWith(color: Colors.white)),
                const SizedBox(height: FxSpacing.xs8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: FxColors.darkSurface,
                        borderRadius: BorderRadius.circular(FxRadii.md12),
                        border: Border.all(color: FxColors.darkBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          dropdownColor: FxColors.darkSurface,
                          style: FxTypography.bodyMedium.copyWith(color: Colors.white),
                          icon: const Icon(Icons.keyboard_arrow_down, color: FxColors.darkTextSecondary, size: 18),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCountryCode = val);
                          },
                          items: _countries.map((c) {
                            return DropdownMenuItem<String>(
                              value: c["code"],
                              child: Text("${c["flag"]} ${c["code"]}"),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: FxSpacing.sm10),
                    Expanded(
                      child: FxTextField(
                        controller: _phoneController,
                        hintText: "690000000",
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FxSpacing.xxl24),
                FxButton(
                  text: "Envoyer le code SMS",
                  isLoading: _isLoading,
                  onPressed: _requestResetCode,
                ),
              ] else ...[
                Text("Code de vérification SMS (6 chiffres)", style: FxTypography.labelLarge.copyWith(color: Colors.white)),
                const SizedBox(height: FxSpacing.xs8),
                FxTextField(
                  controller: _otpController,
                  hintText: "123456",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: FxSpacing.xl20),
                Text("Nouveau mot de passe", style: FxTypography.labelLarge.copyWith(color: Colors.white)),
                const SizedBox(height: FxSpacing.xs8),
                FxTextField(
                  controller: _newPasswordController,
                  hintText: "Au moins 6 caractères",
                  obscureText: _isPasswordObscured,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: FxColors.darkTextSecondary,
                    ),
                    onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
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
