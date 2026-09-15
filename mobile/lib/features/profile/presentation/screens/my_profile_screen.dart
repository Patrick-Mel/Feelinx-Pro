import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_avatar.dart';
import '../../../../core/network/dio_client.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  dynamic _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyProfile();
  }

  Future<void> _fetchMyProfile() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('profiles/me/');
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _profile = res.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photos = _profile?['photos'] as List? ?? [];
    final photoUrl = photos.isNotEmpty ? photos.first['url'] : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil", style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar Header
              Center(
                child: Column(
                  children: [
                    FxAvatar(
                      imageUrl: photoUrl,
                      radius: 48,
                      isVerified: _profile?['is_verified'] == true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${_profile?['first_name'] ?? 'Membre'}, ${_profile?['age'] ?? 24}", style: FxTypography.titleLarge),
                        if (_profile?['is_verified'] == true) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: FxColors.info, size: 20),
                        ],
                      ],
                    ),
                    Text("${_profile?['city']} • Profil complété à 85%", style: FxTypography.bodyMedium.copyWith(color: FxColors.darkTextSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Premium Banner Card
              InkWell(
                onTap: () => context.push('/premium'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [FxColors.accentGold, FxColors.primaryCoral]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Feelinx Premium", style: FxTypography.titleMedium.copyWith(color: Colors.white)),
                            const SizedBox(height: 2),
                            Text("Likes illimités, voir qui vous a liké & plus encore", style: FxTypography.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action List Tiles
              _buildSettingTile(Icons.edit, "Modifier mon profil", () => context.push('/profile/edit')),
              _buildSettingTile(Icons.photo_library, "Mes photos", () => context.push('/profile/photos')),
              _buildSettingTile(
                Icons.verified_user,
                _profile?['is_verified'] == true ? "Compte Certifié" : "Certification de compte",
                () => context.push('/safety/verification'),
              ),
              _buildSettingTile(Icons.shield, "Centre de Sécurité & Protection", () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.security, color: FxColors.primaryCoral),
                        SizedBox(width: 8),
                        Text("Centre de Sécurité"),
                      ],
                    ),
                    content: const Text(
                      "Feelinx est équipé d'un système intelligent anti-arnaque et de détection des profils frauduleux.\n\n"
                      "• Faites certifier votre compte avec un selfie pour obtenir le badge de vérification.\n"
                      "• Signalez ou bloquez tout comportement suspect.\n"
                      "• Ne partagez jamais vos informations financières ou bancaires.",
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Compris")),
                    ],
                  ),
                );
              }),
              _buildSettingTile(Icons.settings, "Paramètres", () => context.push('/settings')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: FxColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: FxColors.primaryCoral),
        title: Text(title, style: FxTypography.bodyLarge),
        trailing: const Icon(Icons.chevron_right, color: FxColors.darkTextSecondary),
        onTap: onTap,
      ),
    );
  }
}
