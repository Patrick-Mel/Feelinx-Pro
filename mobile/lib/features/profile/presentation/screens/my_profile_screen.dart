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
    final rawUrl = photos.isNotEmpty ? (photos.first['url'] ?? photos.first['image'] ?? '') : '';
    final String? photoUrl = rawUrl.isNotEmpty ? DioClient.resolveImageUrl(rawUrl) : null;
    final completion = _profile?['profile_completion'] ?? 85;
    final bio = _profile?['bio'] ?? '';
    final city = _profile?['city'] ?? 'Cameroun';

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? (isDarkMode ? FxColors.darkCard : FxColors.lightCard);
    final borderBg = isDarkMode ? FxColors.darkBorder : FxColors.lightBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDarkMode ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil", style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await context.push('/settings');
              _fetchMyProfile();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchMyProfile,
          color: FxColors.primaryCoral,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Header
                Center(
                  child: Column(
                    children: [
                      FxAvatar(
                        imageUrl: photoUrl,
                        radius: 52,
                        isVerified: _profile?['is_verified'] == true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${_profile?['full_name'] ?? _profile?['first_name'] ?? 'Membre'}, ${_profile?['age'] ?? 24}",
                            style: FxTypography.displayMedium.copyWith(fontSize: 22, color: textPrimary),
                          ),
                          if (_profile?['is_verified'] == true) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: FxColors.info, size: 22),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$city • Profil complété à $completion%",
                        style: FxTypography.bodyMedium.copyWith(color: textSecondary),
                      ),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderBg),
                          ),
                          child: Text(
                            bio,
                            textAlign: TextAlign.center,
                            style: FxTypography.bodyMedium.copyWith(color: textSecondary, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),


                // Action List Tiles
                _buildSettingTile(Icons.edit, "Modifier mon profil", () async {
                  await context.push('/profile/edit');
                  _fetchMyProfile();
                }, textPrimary, cardBg, borderBg, textSecondary),
                _buildSettingTile(Icons.photo_library, "Mes photos", () async {
                  await context.push('/profile/photos');
                  _fetchMyProfile();
                }, textPrimary, cardBg, borderBg, textSecondary),
                _buildSettingTile(
                  Icons.verified_user,
                  _profile?['is_verified'] == true ? "Compte Certifié" : "Certification de compte",
                  () async {
                    await context.push('/safety/verification');
                    _fetchMyProfile();
                  },
                  textPrimary, cardBg, borderBg, textSecondary
                ),
                _buildSettingTile(Icons.shield, "Centre de Sécurité & Protection", () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: cardBg,
                      title: Row(
                        children: [
                          const Icon(Icons.security, color: FxColors.primaryCoral),
                          const SizedBox(width: 8),
                          Text("Centre de Sécurité", style: TextStyle(color: textPrimary)),
                        ],
                      ),
                      content: Text(
                        "Feelinx est équipé d'un système intelligent anti-arnaque et de détection des profils frauduleux.\n\n"
                        "• Faites certifier votre compte avec un selfie pour obtenir le badge de vérification.\n"
                        "• Signalez ou bloquez tout comportement suspect.\n"
                        "• Ne partagez jamais vos informations financières ou bancaires.",
                        style: TextStyle(color: textSecondary),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Compris")),
                      ],
                    ),
                  );
                }, textPrimary, cardBg, borderBg, textSecondary),
                _buildSettingTile(Icons.settings, "Paramètres", () async {
                  await context.push('/settings');
                  _fetchMyProfile();
                }, textPrimary, cardBg, borderBg, textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap, Color textPrimary, Color cardBg, Color borderBg, Color textSecondary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderBg),
      ),
      child: ListTile(
        leading: Icon(icon, color: FxColors.primaryCoral),
        title: Text(title, style: FxTypography.bodyLarge.copyWith(color: textPrimary)),
        trailing: Icon(Icons.chevron_right, color: textSecondary),
        onTap: onTap,
      ),
    );
  }
}
