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

    final RegExp phoneRegex = RegExp(r'^[0-9]{8,10}$');
    if (!phoneRegex.hasMatch(phone)) {
      setState(() => _errorMessage = "Veuillez entrer un numéro valide à 8, 9 ou 10 chiffres (ex: 690123456)");
      return;
    }

    if (Set.from(phone.split('')).length == 1) {
      setState(() => _errorMessage = "Les numéros avec chiffres répétitifs (ex: 00000000) ne sont pas autorisés.");
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
      final serverMsg = e.response?.data?['message'];
      String msg = "Impossible de contacter le serveur. Vérifiez votre connexion.";
      if (serverMsg is String && serverMsg.isNotEmpty) {
        msg = serverMsg;
      } else if (e.response?.data?['phone_number'] is List) {
        msg = (e.response!.data['phone_number'] as List).first.toString();
      }
      setState(() {
        _errorMessage = msg;
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
