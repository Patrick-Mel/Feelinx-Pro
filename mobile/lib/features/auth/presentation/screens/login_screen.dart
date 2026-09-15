import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCountryCode = "+237";
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, String>> _countries = [
    {"code": "+237", "flag": "🇨🇲", "name": "Cameroun"},
    {"code": "+225", "flag": "🇨🇮", "name": "Côte d'Ivoire"},
    {"code": "+221", "flag": "🇸🇳", "name": "Sénégal"},
    {"code": "+242", "flag": "🇨🇬", "name": "Congo"},
    {"code": "+243", "flag": "🇨🇩", "name": "RDC"},
    {"code": "+33",  "flag": "🇫🇷", "name": "France"},
  ];

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhone = "$_selectedCountryCode$phone";

    try {
      final dio = DioClient().dio;
      final res = await dio.post('auth/login/', data: {
        'phone_number': fullPhone,
        'password': password,
      });

      if (res.statusCode == 200 && mounted) {
        final access = res.data['access'];
        final refresh = res.data['refresh'];
        final hasProfile = res.data['has_profile'] == true;

        final storage = StorageService();
        await storage.saveAccessToken(access);
        await storage.saveRefreshToken(refresh);

        if (hasProfile) {
          context.go('/discovery');
        } else {
          context.go('/onboarding/wizard');
        }
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      String msg = "Identifiants incorrects. Veuillez réessayer.";
      if (serverMsg is String && serverMsg.isNotEmpty) {
        msg = serverMsg;
      }
      setState(() => _errorMessage = msg);
    } catch (_) {
      setState(() => _errorMessage = "Une erreur est survenue lors de la connexion.");
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
                "Bon retour parmi nous !",
                style: FxTypography.displayMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FxSpacing.xs8),
              Text(
                "Connectez-vous pour retrouver vos matchs et vos messages.",
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
                        child: Text(
                          _errorMessage!,
                          style: FxTypography.bodySmall.copyWith(color: FxColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FxSpacing.lg16),
              ],

              // Phone Number Field
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
              const SizedBox(height: FxSpacing.xl20),

              // Password Field
              Text("Mot de passe", style: FxTypography.labelLarge.copyWith(color: Colors.white)),
              const SizedBox(height: FxSpacing.xs8),
              FxTextField(
                controller: _passwordController,
                hintText: "••••••••",
                obscureText: _isPasswordObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: FxColors.darkTextSecondary,
                  ),
                  onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                ),
              ),
              const SizedBox(height: FxSpacing.sm10),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/auth/forgot-password'),
                  child: Text(
                    "Mot de passe oublié ?",
                    style: FxTypography.bodySmall.copyWith(
                      color: FxColors.primaryCoral,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: FxSpacing.xxl24),

              FxButton(
                text: "Se connecter",
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: FxSpacing.lg16),

              // Alternative login option by SMS
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/auth/phone'),
                  icon: const Icon(Icons.sms_outlined, size: 18, color: FxColors.secondaryAmethyst),
                  label: Text(
                    "Se connecter par SMS / Code OTP",
                    style: FxTypography.bodyMedium.copyWith(color: FxColors.secondaryAmethyst, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: FxSpacing.xxxl32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Nouveau sur Feelinx ? ", style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary)),
                  GestureDetector(
                    onTap: () => context.go('/auth/register'),
                    child: Text(
                      "Créer un compte",
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
