import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_button.dart';
import '../../../../core/network/dio_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _maxDistance = 50;
  RangeValues _ageRange = const RangeValues(18, 45);
  bool _verifiedOnly = false;
  bool _incognito = false;
  bool _isDarkMode = true;
  String _selectedLanguage = 'fr'; // 'fr' or 'en'
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur débloqué.")),
        );
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
                    Text("Apparence & Langue", style: FxTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: FxColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: Icon(
                              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              color: FxColors.primaryCoral,
                            ),
                            title: const Text("Mode Sombre / Clair"),
                            subtitle: Text(
                              _isDarkMode ? "Thème sombre Feelinx actif" : "Thème clair actif",
                              style: const TextStyle(color: FxColors.darkTextSecondary, fontSize: 12),
                            ),
                            value: _isDarkMode,
                            activeColor: FxColors.primaryCoral,
                            onChanged: (val) {
                              setState(() => _isDarkMode = val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(val ? "Thème Sombre activé 🌙" : "Thème Clair activé ☀️")),
                              );
                            },
                          ),
                          const Divider(height: 1, color: FxColors.darkBorder),
                          ListTile(
                            leading: const Icon(Icons.language, color: FxColors.primaryCoral),
                            title: const Text("Langue de l'application"),
                            subtitle: Text(
                              _selectedLanguage == 'fr' ? "Français 🇫🇷" : "English 🇬🇧",
                              style: const TextStyle(color: FxColors.darkTextSecondary, fontSize: 12),
                            ),
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLanguage,
                                dropdownColor: FxColors.darkSurface,
                                style: FxTypography.bodyMedium.copyWith(color: Colors.white),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedLanguage = val);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(val == 'fr' ? "Langue : Français 🇫🇷" : "Language: English 🇬🇧")),
                                    );
                                  }
                                },
                                items: _languages.map((l) {
                                  return DropdownMenuItem<String>(
                                    value: l["code"],
                                    child: Text(l["label"]!),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filtres de découverte Section
                    Text("Filtres de découverte", style: FxTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    Text("Distance maximale : ${_maxDistance.round()} km", style: FxTypography.titleMedium),
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

                    Text("Tranche d'âge : ${_ageRange.start.round()} - ${_ageRange.end.round()} ans", style: FxTypography.titleMedium),
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
                      title: const Text("Afficher uniquement les profils certifiés"),
                      value: _verifiedOnly,
                      activeColor: FxColors.primaryCoral,
                      onChanged: (val) {
                        setState(() => _verifiedOnly = val);
                        _updatePreferences();
                      },
                    ),
                    SwitchListTile(
                      title: const Text("Mode Incognito"),
                      subtitle: const Text("Masque votre profil dans le fil sauf aux personnes que vous avez likées"),
                      value: _incognito,
                      activeColor: FxColors.primaryCoral,
                      onChanged: (val) {
                        setState(() => _incognito = val);
                        _updatePreferences();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Confidentialité Section
                    Text("Gestion de la confidentialité", style: FxTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
