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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedCountryCode = "+237";
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, String>> _countries = const [
    {"code": "+237", "flag": "🇨🇲", "name": "Cameroun"},
    {"code": "+225", "flag": "🇨🇮", "name": "Côte d'Ivoire"},
    {"code": "+221", "flag": "🇸🇳", "name": "Sénégal"},
    {"code": "+242", "flag": "🇨🇬", "name": "Congo"},
    {"code": "+243", "flag": "🇨🇩", "name": "RDC"},
    {"code": "+33",  "flag": "🇫🇷", "name": "France"},
  ];

  Future<void> _handleRegister() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs.");
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

    final fullPhone = "$_selectedCountryCode$phone";

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
    return Scaffold(
      backgroundColor: FxColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
                style: FxTypography.displayMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FxSpacing.sm8),
              Text(
                "Rejoignez la communauté de rencontres la plus exclusive et authentique.",
                style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary),
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

              // Phone Field
              Text("Numéro de téléphone", style: FxTypography.titleMedium.copyWith(color: Colors.white)),
              const SizedBox(height: FxSpacing.sm8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: FxColors.darkSurface,
                      borderRadius: BorderRadius.circular(FxRadius.medium16),
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
                  const SizedBox(width: FxSpacing.sm8),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: FxTypography.bodyLarge.copyWith(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "690000000",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FxSpacing.xl20),

              // Password Field
              Text("Mot de passe", style: FxTypography.titleMedium.copyWith(color: Colors.white)),
              const SizedBox(height: FxSpacing.sm8),
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordObscured,
                style: FxTypography.bodyLarge.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Au moins 6 caractères",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: FxColors.darkTextSecondary,
                    ),
                    onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                  ),
                ),
              ),
              const SizedBox(height: FxSpacing.xl20),

              // Confirm Password Field
              Text("Confirmer le mot de passe", style: FxTypography.titleMedium.copyWith(color: Colors.white)),
              const SizedBox(height: FxSpacing.sm8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isPasswordObscured,
                style: FxTypography.bodyLarge.copyWith(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Répétez le mot de passe",
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
                  Text("Vous avez déjà un compte ? ", style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary)),
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
