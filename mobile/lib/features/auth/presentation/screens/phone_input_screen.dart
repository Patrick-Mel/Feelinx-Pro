import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/widgets/fx_phone_field.dart';
import '../../../../core/network/dio_client.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = "+237";
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 8) {
      setState(() => _errorMessage = "Numéro de téléphone invalide (min 8 chiffres)");
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
        final devCode = res.data['dev_code'];
        if (devCode != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Code de test rapide : $devCode"),
              duration: const Duration(seconds: 5),
              backgroundColor: FxColors.info,
            ),
          );
        }
        context.go('/auth/otp', extra: fullPhone);
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['message'] ?? "Impossible de contacter le serveur. Vérifiez votre connexion.";
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
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.xxl24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Numéro de téléphone", style: FxTypography.displayMedium),
              const SizedBox(height: FxSpacing.sm8),
              Text(
                "Un code de vérification à 6 chiffres vous sera envoyé par SMS pour valider votre compte.",
                style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary),
              ),
              const SizedBox(height: FxSpacing.xxxl32),
              FxPhoneField(
                controller: _phoneController,
                countryCode: _selectedCountryCode,
                onCountryChanged: (code) => setState(() => _selectedCountryCode = code),
                errorText: _errorMessage,
                onChanged: (_) {
                  if (_errorMessage != null) setState(() => _errorMessage = null);
                },
              ),
              const Spacer(),
              FxButton(
                text: "Recevoir le code SMS",
                isLoading: _isLoading,
                onPressed: _submitPhone,
              ),
              const SizedBox(height: FxSpacing.lg16),
              Center(
                child: Text(
                  "En continuant, vous acceptez nos CGU et Politique de confidentialité.",
                  style: FxTypography.labelSmall.copyWith(color: FxColors.darkTextSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
