import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryCodeController = TextEditingController(text: "+237");
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  static const List<Map<String, String>> _countryList = [
    {"code": "+237", "name": "Cameroun"},
    {"code": "+225", "name": "Côte d'Ivoire"},
    {"code": "+221", "name": "Sénégal"},
    {"code": "+242", "name": "Congo"},
    {"code": "+243", "name": "RDC"},
    {"code": "+241", "name": "Gabon"},
    {"code": "+235", "name": "Tchad"},
    {"code": "+236", "name": "Centrafrique"},
    {"code": "+223", "name": "Mali"},
    {"code": "+226", "name": "Burkina Faso"},
    {"code": "+228", "name": "Togo"},
    {"code": "+229", "name": "Bénin"},
    {"code": "+224", "name": "Guinée"},
    {"code": "+250", "name": "Rwanda"},
    {"code": "+257", "name": "Burundi"},
    {"code": "+227", "name": "Niger"},
    {"code": "+234", "name": "Nigéria"},
    {"code": "+233", "name": "Ghana"},
    {"code": "+254", "name": "Kenya"},
    {"code": "+27",  "name": "Afrique du Sud"},
    {"code": "+33",  "name": "France"},
    {"code": "+1",   "name": "Canada / USA"},
    {"code": "+32",  "name": "Belgique"},
    {"code": "+41",  "name": "Suisse"},
    {"code": "+212", "name": "Maroc"},
    {"code": "+216", "name": "Tunisie"},
    {"code": "+213", "name": "Algérie"},
  ];

  Map<String, String> _getDetectedCountry(String rawCode) {
    String clean = rawCode.replaceAll(RegExp(r'[^\d+]'), '');
    if (!clean.startsWith('+')) {
      clean = '+$clean';
    }
    for (var c in _countryList) {
      if (clean == c['code'] || clean.startsWith(c['code']!)) {
        return c;
      }
    }
    return {"code": clean, "name": "International"};
  }

  void _nextStep() {
    setState(() => _errorMessage = null);
    if (_currentStep == 0) {
      if (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty) {
        setState(() => _errorMessage = "Veuillez saisir votre prénom et votre nom.");
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_phoneController.text.trim().isEmpty) {
        setState(() => _errorMessage = "Veuillez entrer un numéro de téléphone valide.");
        return;
      }
      setState(() => _currentStep = 2);
    }
  }

  void _previousStep() {
    setState(() {
      _errorMessage = null;
      if (_currentStep > 0) {
        _currentStep--;
      } else {
        context.go('/onboarding');
      }
    });
  }

  Future<void> _handleRegister() async {
    final firstName = _firstNameController.text.trim();
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
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: _previousStep,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: FxSpacing.xxl24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar (Step Indicator)
              Row(
                children: List.generate(3, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
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
                "Étape ${_currentStep + 1} sur 3",
                style: FxTypography.labelSmall.copyWith(color: FxColors.primaryCoral, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FxSpacing.sm8),

              if (_currentStep == 0) ...[
                Text(
                  "Comment vous vous appelez ?",
                  style: FxTypography.displayMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: FxSpacing.sm8),
                Text(
                  "Votre prénom sera affiché sur votre profil Feelinx.",
                  style: FxTypography.bodyMedium.copyWith(color: textSecondary),
                ),
              ] else if (_currentStep == 1) ...[
                Text(
                  "Quel est votre numéro ?",
                  style: FxTypography.displayMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: FxSpacing.sm8),
                Text(
                  "Nous utiliserons ce numéro pour sécuriser votre compte.",
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
                        child: Text(
                          _errorMessage!,
                          style: FxTypography.bodyMedium.copyWith(color: FxColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FxSpacing.lg16),
              ],

              // STEP 0: Identité
              if (_currentStep == 0) ...[
                Text("Prénom", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: FxSpacing.sm8),
                TextField(
                  controller: _firstNameController,
                  style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                  decoration: InputDecoration(hintText: "ex. Manuella", hintStyle: TextStyle(color: textSecondary)),
                ),
                const SizedBox(height: FxSpacing.xl20),
                Text("Nom", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: FxSpacing.sm8),
                TextField(
                  controller: _lastNameController,
                  style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                  decoration: InputDecoration(hintText: "ex. Ndongo", hintStyle: TextStyle(color: textSecondary)),
                ),
                const SizedBox(height: FxSpacing.xxl24),
                FxButton(
                  text: "Continuer",
                  onPressed: _nextStep,
                ),
              ],

              // STEP 1: Numéro de téléphone
              if (_currentStep == 1) ...[
                FxPhoneField(
                  controller: _phoneController,
                  countryCode: _countryCodeController.text,
                  onCountryChanged: (code) => setState(() => _countryCodeController.text = code),
                ),
                const SizedBox(height: FxSpacing.xxl24),
                FxButton(
                  text: "Continuer",
                  onPressed: _nextStep,
                ),
              ],

              // STEP 2: Mot de passe
              if (_currentStep == 2) ...[
                Text("Mot de passe", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: FxSpacing.sm8),
                TextField(
                  controller: _passwordController,
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
                const SizedBox(height: FxSpacing.xl20),
                Text("Confirmer le mot de passe", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: FxSpacing.sm8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: "Répétez le mot de passe",
                    hintStyle: TextStyle(color: textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: textSecondary,
                      ),
                      onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                    ),
                  ),
                ),
                const SizedBox(height: FxSpacing.xxl24),
                FxButton(
                  text: "Créer mon compte",
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
              ],

              const SizedBox(height: FxSpacing.xxxl32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous avez déjà un compte ? ", style: FxTypography.bodyMedium.copyWith(color: textSecondary)),
                  GestureDetector(
                    onTap: () => context.go('/auth/login'),
                    child: Text(
                      "Se connecter",
                      style: FxTypography.bodyMedium.copyWith(color: FxColors.primaryCoral, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FxSpacing.xxl24),
            ],
          ),
        ),
      ),
    );
  }
}
