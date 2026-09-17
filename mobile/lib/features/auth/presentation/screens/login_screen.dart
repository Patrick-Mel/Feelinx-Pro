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

  final List<Map<String, String>> _countries = const [
    {"code": "+237", "name": "Cameroun"},
    {"code": "+225", "name": "Côte d'Ivoire"},
    {"code": "+221", "name": "Sénégal"},
    {"code": "+242", "name": "Congo"},
    {"code": "+243", "name": "RDC"},
    {"code": "+33",  "name": "France"},
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

        const storage = FlutterSecureStorage();
        await storage.write(key: 'jwt_access_token', value: access);
        await storage.write(key: 'jwt_refresh_token', value: refresh);

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
                "Bon retour parmi nous !",
                style: FxTypography.displayMedium.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FxSpacing.sm8),
              Text(
                "Connectez-vous pour retrouver vos matchs et vos messages.",
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

              // Phone Field
              FxPhoneField(
                controller: _phoneController,
                countryCode: _selectedCountryCode,
                onCountryChanged: (code) => setState(() => _selectedCountryCode = code),
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
                  hintText: "••••••••",
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
              const SizedBox(height: FxSpacing.sm8),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/auth/forgot-password'),
                  child: Text(
                    "Mot de passe oublié ?",
                    style: FxTypography.bodyMedium.copyWith(
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

              const SizedBox(height: FxSpacing.xxxl32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Nouveau sur Feelinx ? ", style: FxTypography.bodyMedium.copyWith(color: textSecondary)),
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
