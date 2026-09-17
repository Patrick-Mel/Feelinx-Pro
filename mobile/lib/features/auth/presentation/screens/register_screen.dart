import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_text_field.dart';
import '../../../../core/widgets/fx_phone_field.dart';
import '../../../../core/network/dio_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;

  final TextEditingController _countryCodeController = TextEditingController(text: "+237");
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _errorMessage = null);

    if (_currentStep == 0) {
      if (_phoneController.text.trim().isEmpty) {
        setState(() => _errorMessage = "Veuillez entrer votre numéro de téléphone.");
        return;
      }
      setState(() => _currentStep = 1);
    } else {
      _handleRegister();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _errorMessage = null;
        _currentStep--;
      });
    }
  }

  Future<void> _handleRegister() async {
    final countryCode = _countryCodeController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir le mot de passe.");
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = "Le mot de passe doit contenir au moins 6 caractères.");
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = "Les mots de passe ne correspondent pas.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefix = countryCode.startsWith('+') ? countryCode : '+$countryCode';
    final fullPhone = "$prefix$phone";

    try {
      final dio = DioClient().dio;
      final res = await dio.post('auth/register/', data: {
        'phone_number': fullPhone,
        'password': password,
      });

      if (res.statusCode == 201 && mounted) {
        final access = res.data['access'];
        final refresh = res.data['refresh'];

        const storage = FlutterSecureStorage();
        await storage.write(key: 'jwt_access_token', value: access);
        await storage.write(key: 'jwt_refresh_token', value: refresh);

        context.go('/onboarding/wizard');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      String msg = "Impossible de créer le compte. Vérifiez votre numéro.";
      if (serverMsg is String && serverMsg.isNotEmpty) {
        msg = serverMsg;
      }
      setState(() => _errorMessage = msg);
    } catch (_) {
      setState(() => _errorMessage = "Une erreur est survenue lors de l'inscription.");
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
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              context.go('/onboarding');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: FxSpacing.xxl24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Bar (Step Indicator: 2 Steps total)
                      Row(
                        children: List.generate(2, (index) {
                          final isActive = index <= _currentStep;
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 4,
                              margin: EdgeInsets.only(right: index < 1 ? 8 : 0),
                              decoration: BoxDecoration(
                                color: isActive ? FxColors.primaryCoral : (isDark ? Colors.white24 : Colors.black12),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: FxSpacing.md12),
                      Text(
                        "Étape ${_currentStep + 1} sur 2",
                        style: FxTypography.labelSmall.copyWith(color: FxColors.primaryCoral, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: FxSpacing.sm8),

                      if (_currentStep == 0) ...[
                        Text(
                          "Quel est votre numéro ?",
                          style: FxTypography.displayMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: FxSpacing.sm8),
                        Text(
                          "Nous utiliserons ce numéro pour sécuriser votre compte Feelinx.",
                          style: FxTypography.bodyMedium.copyWith(color: textSecondary),
                        ),
                      ] else ...[
                        Text(
                          "Sécurisez votre compte",
                          style: FxTypography.displayMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: FxSpacing.sm8),
                        Text(
                          "Choisissez un mot de passe robuste d'au moins 6 caractères.",
                          style: FxTypography.bodyMedium.copyWith(color: textSecondary),
                        ),
                      ],

                      const SizedBox(height: FxSpacing.xxxl32),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(FxSpacing.md12),
                          decoration: BoxDecoration(
                            color: FxColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: FxColors.error.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: FxColors.error, size: 20),
                              const SizedBox(width: FxSpacing.sm8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: FxColors.error, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FxSpacing.lg16),
                      ],

                      if (_currentStep == 0) ...[
                        FxPhoneField(
                          controller: _phoneController,
                          countryCode: _countryCodeController.text,
                          onCountryChanged: (code) {
                            setState(() {
                              _countryCodeController.text = code;
                            });
                          },
                        ),
                      ] else ...[
                        FxTextField(
                          label: "Mot de passe",
                          hint: "••••••••••••",
                          obscureText: !_isPasswordVisible,
                          controller: _passwordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: textSecondary,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: FxSpacing.lg16),
                        FxTextField(
                          label: "Confirmer le mot de passe",
                          hint: "••••••••••••",
                          obscureText: !_isConfirmPasswordVisible,
                          controller: _confirmPasswordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: textSecondary,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Pinned Bottom Mobile Action Bar
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FxButton(
                    text: _currentStep == 0 ? "CONTINUER" : "CRÉER MON COMPTE",
                    isLoading: _isLoading,
                    onPressed: _nextStep,
                  ),
                  const SizedBox(height: FxSpacing.lg16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: RichText(
                        text: TextSpan(
                          text: "Déjà membre ? ",
                          style: FxTypography.bodyMedium.copyWith(color: textSecondary),
                          children: const [
                            TextSpan(
                              text: "Se connecter",
                              style: TextStyle(color: FxColors.primaryCoral, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: FxSpacing.md12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
