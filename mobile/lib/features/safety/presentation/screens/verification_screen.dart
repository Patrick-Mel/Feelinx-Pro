import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';

import '../../../../core/network/dio_client.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;
  bool _isVerified = false;

  Future<void> _submitSelfie() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;
      final res = await dio.post('profiles/me/verify/');
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _isVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Badge de vérification bleu activé ! 🛡️"),
            backgroundColor: FxColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de la vérification."),
            backgroundColor: FxColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification par Selfie 🛡️", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.xxl24),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isVerified ? FxColors.success.withOpacity(0.15) : FxColors.info.withOpacity(0.15),
                ),
                child: Icon(
                  _isVerified ? Icons.verified : Icons.camera_alt,
                  size: 64,
                  color: _isVerified ? FxColors.success : FxColors.info,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isVerified ? "Ton compte est vérifié !" : "Reproduis la pose demandée",
                style: FxTypography.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isVerified
                    ? "Le badge bleu est maintenant affiché sur ton profil pour prouver ton authenticité."
                    : "Pour obtenir le badge bleu, prends un selfie en faisant le signe V avec tes doigts (✌️).",
                style: FxTypography.bodyLarge.copyWith(color: FxColors.darkTextSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (!_isVerified)
                FxButton(
                  text: "Prendre mon selfie 📸",
                  isLoading: _isLoading,
                  onPressed: _submitSelfie,
                )
              else
                FxButton(
                  text: "Retour à mon profil",
                  onPressed: () => context.pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
