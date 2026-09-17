import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    {"code": "+237", "flag": "🇨🇲", "name": "Cameroun"},
    {"code": "+225", "flag": "🇨🇮", "name": "Côte d'Ivoire"},
    {"code": "+221", "flag": "🇸🇳", "name": "Sénégal"},
    {"code": "+242", "flag": "🇨🇬", "name": "Congo"},
    {"code": "+243", "flag": "🇨🇩", "name": "RDC"},
    {"code": "+241", "flag": "🇬🇦", "name": "Gabon"},
    {"code": "+235", "flag": "🇹🇩", "name": "Tchad"},
    {"code": "+236", "flag": "🇨🇫", "name": "Centrafrique"},
    {"code": "+223", "flag": "🇲🇱", "name": "Mali"},
    {"code": "+226", "flag": "🇧🇫", "name": "Burkina Faso"},
    {"code": "+228", "flag": "🇹🇬", "name": "Togo"},
    {"code": "+229", "flag": "🇧🇯", "name": "Bénin"},
    {"code": "+224", "flag": "🇬🇳", "name": "Guinée"},
    {"code": "+250", "flag": "🇷🇼", "name": "Rwanda"},
    {"code": "+257", "flag": "🇧🇮", "name": "Burundi"},
    {"code": "+227", "flag": "🇳🇪", "name": "Niger"},
    {"code": "+234", "flag": "🇳🇬", "name": "Nigéria"},
    {"code": "+233", "flag": "🇬🇭", "name": "Ghana"},
    {"code": "+254", "flag": "🇰🇪", "name": "Kenya"},
    {"code": "+27",  "flag": "🇿🇦", "name": "Afrique du Sud"},
    {"code": "+33",  "flag": "🇫🇷", "name": "France"},
    {"code": "+1",   "flag": "🇨🇦", "name": "Canada / USA"},
    {"code": "+32",  "flag": "🇧🇪", "name": "Belgique"},
    {"code": "+41",  "flag": "🇨🇭", "name": "Suisse"},
    {"code": "+212", "flag": "🇲🇦", "name": "Maroc"},
    {"code": "+216", "flag": "🇹🇳", "name": "Tunisie"},
    {"code": "+213", "flag": "🇩🇿", "name": "Algérie"},
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
    return {"code": clean, "flag": "🌐", "name": "International"};
  }

  Future<void> _handleRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final countryCode = _countryCodeController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs (Prénom, Nom, Téléphone, Mot de passe).");
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
    final containerBg = theme.colorScheme.surface;
    final borderBg = isDark ? FxColors.darkBorder : FxColors.lightBorder;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => context.go('/onboarding'),
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
                "Créer un compte Feelinx",
                style: FxTypography.displayMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FxSpacing.sm8),
              Text(
                "Rejoignez la communauté de rencontres la plus exclusive et authentique.",
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

              // Prénom & Nom Fields
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Prénom", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: FxSpacing.sm8),
                        TextField(
                          controller: _firstNameController,
                          style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                          decoration: InputDecoration(hintText: "ex. Manuella", hintStyle: TextStyle(color: textSecondary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: FxSpacing.md12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nom", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: FxSpacing.sm8),
                        TextField(
                          controller: _lastNameController,
                          style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                          decoration: InputDecoration(hintText: "ex. Ndongo", hintStyle: TextStyle(color: textSecondary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FxSpacing.xl20),

              // Phone Field with Custom Country Code Input & Live Detection Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Numéro de téléphone", style: FxTypography.titleMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                  Builder(
                    builder: (context) {
                      final detected = _getDetectedCountry(_countryCodeController.text);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: FxColors.primaryCoral.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: FxColors.primaryCoral.withOpacity(0.4)),
                        ),
                        child: Text(
                          "${detected['flag']} ${detected['name']}",
                          style: FxTypography.bodyMedium.copyWith(color: FxColors.primaryCoral, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      );
                    }
                  ),
                ],
              ),
              const SizedBox(height: FxSpacing.sm8),
              Row(
                children: [
                  SizedBox(
                    width: 95,
                    child: TextField(
                      controller: _countryCodeController,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                      style: FxTypography.bodyLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "+237",
                        hintStyle: TextStyle(color: textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: FxSpacing.sm8),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: "690000000",
                        hintStyle: TextStyle(color: textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FxSpacing.xl20),

              // Password Field
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

              // Confirm Password Field
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
