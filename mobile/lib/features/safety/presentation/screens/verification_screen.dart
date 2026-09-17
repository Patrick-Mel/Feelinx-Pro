import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _capturedSelfie;
  bool _isLoading = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('profiles/me/');
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _isVerified = res.data['is_verified'] == true;
        });
      }
    } catch (_) {}
  }

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (photo != null && mounted) {
      setState(() {
        _capturedSelfie = photo;
      });
    }
  }

  Future<void> _submitSelfie() async {
    if (_capturedSelfie == null && !_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez d'abord prendre un selfie.")),
      );
      return;
    }

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
            content: Text("Votre compte est désormais certifié et vérifié."),
            backgroundColor: FxColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de la vérification. Réessayez."),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final cardBg = theme.cardTheme.color ?? (isDark ? FxColors.darkCard : FxColors.lightCard);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Certification de compte", style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.xxl24),
          child: Column(
            children: [
              if (_isVerified) ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FxColors.success.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.verified, size: 64, color: FxColors.success),
                ),
                const SizedBox(height: 24),
                Text(
                  "Compte Officiellement Certifié",
                  style: FxTypography.displayMedium.copyWith(color: textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Le badge de certification bleue est affiché sur votre profil pour garantir votre authenticité.",
                  style: FxTypography.bodyLarge.copyWith(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                FxButton(
                  text: "Retour à mon profil",
                  onPressed: () => context.pop(),
                ),
              ] else ...[
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FxColors.primaryCoral.withValues(alpha: 0.3), width: 2),
                  ),
                  child: _capturedSelfie != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(File(_capturedSelfie!.path), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_front, size: 56, color: FxColors.primaryCoral),
                            const SizedBox(height: 12),
                            Text(
                              "Aperçu du Selfie",
                              style: FxTypography.bodyMedium.copyWith(color: textSecondary),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  _capturedSelfie == null ? "Prenez une photo de vérification" : "Selfie prêt pour validation",
                  style: FxTypography.titleLarge.copyWith(color: textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Prenez une photo claire de votre visage pour confirmer votre identité.",
                  style: FxTypography.bodyMedium.copyWith(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: FxButton(
                        text: _capturedSelfie == null ? "Prendre une photo" : "Reprendre",
                        variant: FxButtonVariant.outline,
                        onPressed: _takeSelfie,
                      ),
                    ),
                    if (_capturedSelfie != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FxButton(
                          text: "Valider",
                          isLoading: _isLoading,
                          onPressed: _submitSelfie,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
