import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/app_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _maxDistance = 50;
  RangeValues _ageRange = const RangeValues(18, 45);
  bool _verifiedOnly = false;
  bool _incognito = false;
  bool _isLoading = true;
  List<dynamic> _blockedUsers = [];

  final List<Map<String, String>> _languages = const [
    {"code": "fr", "label": "Français 🇫🇷"},
    {"code": "en", "label": "English 🇬🇧"},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadBlockedUsers();
  }

  Future<void> _loadPreferences() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('profiles/me/preferences/');
      if (res.statusCode == 200 && mounted) {
        final data = res.data;
        setState(() {
          _maxDistance = (data['max_distance_km'] as num? ?? 50).toDouble();
          _ageRange = RangeValues(
            (data['min_age'] as num? ?? 18).toDouble(),
            (data['max_age'] as num? ?? 45).toDouble(),
          );
          _verifiedOnly = data['verified_only'] == true;
          _incognito = data['incognito_mode'] == true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePreferences() async {
    try {
      final dio = DioClient().dio;
      await dio.patch('profiles/me/preferences/', data: {
        'max_distance_km': _maxDistance.round(),
        'min_age': _ageRange.start.round(),
        'max_age': _ageRange.end.round(),
        'verified_only': _verifiedOnly,
        'incognito_mode': _incognito,
      });
    } catch (_) {}
  }

  Future<void> _loadBlockedUsers() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('safety/blocked/');
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _blockedUsers = res.data as List? ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _unblockUser(String blockedId) async {
    try {
      final dio = DioClient().dio;
      await dio.post('safety/unblock/', data: {'user_id': blockedId});
      if (mounted) {
        _loadBlockedUsers();
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'jwt_refresh_token');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final dio = DioClient().dio;
        await dio.post('auth/logout/', data: {'refresh': refreshToken});
      } catch (_) {}
    }
    await storage.deleteAll();
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final bool isDarkMode = themeMode == ThemeMode.dark;
    final String selectedLanguage = locale.languageCode;

    final Color cardBg = isDarkMode ? FxColors.darkCard : FxColors.lightCard;
    final Color borderBg = isDarkMode ? FxColors.darkBorder : FxColors.lightBorder;
    final Color textPrimary = isDarkMode ? FxColors.darkTextPrimary : FxColors.lightTextPrimary;
    final Color textSecondary = isDarkMode ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final Color surfaceBg = isDarkMode ? FxColors.darkSurface : FxColors.lightSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Apparence & Langue Section
                    Text(
                      "Apparence & Langue",
                      style: FxTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderBg),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: Icon(
                              isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              color: FxColors.primaryCoral,
                            ),
                            title: Text(
                              "Mode Sombre / Clair",
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              isDarkMode ? "Thème sombre Feelinx actif" : "Thème clair actif",
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                            value: isDarkMode,
                            activeColor: FxColors.primaryCoral,
                            onChanged: (val) {
                              ref.read(themeModeProvider.notifier).toggleTheme(val);
                            },
                          ),
                          Divider(height: 1, color: borderBg),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.language, color: FxColors.primaryCoral),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Langue de l'application",
                                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedLanguage == 'fr' ? "Français 🇫🇷" : "English 🇬🇧",
                                        style: TextStyle(color: textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: surfaceBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderBg),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedLanguage,
                                      isDense: true,
                                      dropdownColor: surfaceBg,
                                      style: FxTypography.bodyMedium.copyWith(color: textPrimary),
                                      onChanged: (val) {
                                        if (val != null) {
                                          ref.read(localeProvider.notifier).setLocale(val);
                                        }
                                      },
                                      items: _languages.map((l) {
                                        return DropdownMenuItem<String>(
                                          value: l["code"],
                                          child: Text(
                                            l["label"]!,
                                            style: TextStyle(color: textPrimary),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filtres de découverte Section
                    Text("Filtres de découverte", style: FxTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    Text("Distance maximale : ${_maxDistance.round()} km", style: FxTypography.titleMedium.copyWith(color: textPrimary)),
                    Slider(
                      value: _maxDistance,
                      min: 5,
                      max: 150,
                      divisions: 29,
                      activeColor: FxColors.primaryCoral,
                      onChanged: (val) {
                        setState(() => _maxDistance = val);
                        _updatePreferences();
                      },
                    ),
                    const SizedBox(height: 16),

                    Text("Tranche d'âge : ${_ageRange.start.round()} - ${_ageRange.end.round()} ans", style: FxTypography.titleMedium.copyWith(color: textPrimary)),
                    RangeSlider(
                      values: _ageRange,
                      min: 18,
                      max: 65,
                      divisions: 47,
                      activeColor: FxColors.primaryCoral,
                      onChanged: (val) {
                        setState(() => _ageRange = val);
                        _updatePreferences();
                      },
                    ),
                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: Text("Afficher uniquement les profils certifiés", style: TextStyle(color: textPrimary)),
                      value: _verifiedOnly,
                      activeThumbColor: FxColors.primaryCoral,
                      onChanged: (val) {
                        setState(() => _verifiedOnly = val);
                        _updatePreferences();
                      },
                    ),
                    SwitchListTile(
                      title: Text("Mode Incognito", style: TextStyle(color: textPrimary)),
                      subtitle: Text("Masque votre profil dans le fil sauf aux personnes que vous avez likées", style: TextStyle(color: textSecondary)),
                      value: _incognito,
                      activeThumbColor: FxColors.primaryCoral,
                      onChanged: (val) {
                        setState(() => _incognito = val);
                        _updatePreferences();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Confidentialité Section
                    Text("Gestion de la confidentialité", style: FxTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.block, color: FxColors.error),
                      title: Text("Utilisateurs bloqués (${_blockedUsers.length})", style: FxTypography.bodyLarge),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: FxColors.darkSurface,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Comptes bloqués", style: FxTypography.titleLarge),
                                const SizedBox(height: 12),
                                if (_blockedUsers.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: Text("Aucun utilisateur bloqué.", style: TextStyle(color: FxColors.darkTextSecondary))),
                                  )
                                else
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _blockedUsers.length,
                                      itemBuilder: (context, index) {
                                        final u = _blockedUsers[index];
                                        return ListTile(
                                          title: Text(u['blocked_name'] ?? 'Utilisateur'),
                                          trailing: TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _unblockUser(u['blocked_id']);
                                            },
                                            child: const Text("Débloquer", style: TextStyle(color: FxColors.primaryCoral)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    FxButton(
                      text: "Se déconnecter",
                      variant: FxButtonVariant.outline,
                      onPressed: _logout,
                    ),
                    const SizedBox(height: 12),
                    FxButton(
                      text: "Supprimer définitivement mon compte",
                      variant: FxButtonVariant.danger,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Suppression de compte"),
                            content: const Text("Es-tu sûr(e) de vouloir supprimer définitivement ton compte Feelinx ? Toutes tes données et conversations seront détruites."),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
                              TextButton(onPressed: () {
                                Navigator.pop(context);
                                _logout();
                              }, child: const Text("Supprimer", style: TextStyle(color: FxColors.error))),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
