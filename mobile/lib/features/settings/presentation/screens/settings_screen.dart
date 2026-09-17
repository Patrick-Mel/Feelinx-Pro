import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';
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
    {"code": "fr", "label": "Français"},
    {"code": "en", "label": "English"},
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
    final bool isDarkMode = themeMode == ThemeMode.dark;
    final String selectedLanguage = context.locale.languageCode;

    final theme = Theme.of(context);
    final cardBg = theme.cardTheme.color ?? (isDarkMode ? FxColors.darkCard : FxColors.lightCard);
    final borderBg = isDarkMode ? FxColors.darkBorder : FxColors.lightBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDarkMode ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final surfaceBg = theme.colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings.title'), style: const TextStyle(fontWeight: FontWeight.w800)),
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
                      context.tr('settings.appearance_language'),
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
                              context.tr('settings.dark_light_mode'),
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              isDarkMode ? context.tr('settings.dark_active') : context.tr('settings.light_active'),
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                            value: isDarkMode,
                            activeThumbColor: FxColors.primaryCoral,
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
                                        context.tr('settings.app_language'),
                                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedLanguage == 'fr' ? "Français" : "English",
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
                                          ref.read(localeProvider.notifier).setLocale(val, context);
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
                    Text(
                      context.tr('settings.discovery_filters'),
                      style: FxTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      context.tr('settings.max_distance', args: ['${_maxDistance.round()}']),
                      style: FxTypography.titleMedium.copyWith(color: textPrimary),
                    ),
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

                    Text(
                      context.tr('settings.age_range', args: ['${_ageRange.start.round()}', '${_ageRange.end.round()}']),
                      style: FxTypography.titleMedium.copyWith(color: textPrimary),
                    ),
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
                      title: Text(context.tr('settings.verified_only'), style: TextStyle(color: textPrimary)),
                      value: _verifiedOnly,
                      activeThumbColor: FxColors.primaryCoral,
                      onChanged: (val) {
                        setState(() => _verifiedOnly = val);
                        _updatePreferences();
                      },
                    ),
                    SwitchListTile(
                      title: Text(context.tr('settings.incognito'), style: TextStyle(color: textPrimary)),
                      subtitle: Text(context.tr('settings.incognito_desc'), style: TextStyle(color: textSecondary)),
                      value: _incognito,
                      activeThumbColor: FxColors.primaryCoral,
                      onChanged: (val) {
                        setState(() => _incognito = val);
                        _updatePreferences();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Confidentialité Section
                    Text(
                      context.tr('settings.privacy'),
                      style: FxTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.block, color: FxColors.error),
                      title: Text(
                        context.tr('settings.blocked_users', args: ['${_blockedUsers.length}']),
                        style: FxTypography.bodyLarge.copyWith(color: textPrimary),
                      ),
                      trailing: Icon(Icons.chevron_right, color: textSecondary),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: surfaceBg,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.tr('settings.blocked_title'), style: FxTypography.titleLarge.copyWith(color: textPrimary)),
                                const SizedBox(height: 12),
                                if (_blockedUsers.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: Text(context.tr('settings.no_blocked'), style: TextStyle(color: textSecondary))),
                                  )
                                else
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _blockedUsers.length,
                                      itemBuilder: (context, index) {
                                        final u = _blockedUsers[index];
                                        return ListTile(
                                          title: Text(u['blocked_name'] ?? 'Utilisateur', style: TextStyle(color: textPrimary)),
                                          trailing: TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _unblockUser(u['blocked_id']);
                                            },
                                            child: Text(context.tr('settings.unblock'), style: const TextStyle(color: FxColors.primaryCoral)),
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
                      text: context.tr('settings.logout'),
                      variant: FxButtonVariant.outline,
                      onPressed: _logout,
                    ),
                    const SizedBox(height: 12),
                    FxButton(
                      text: context.tr('settings.delete_account'),
                      variant: FxButtonVariant.danger,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: surfaceBg,
                            title: Text(context.tr('settings.delete_title'), style: TextStyle(color: textPrimary)),
                            content: Text(context.tr('settings.delete_confirm'), style: TextStyle(color: textSecondary)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('settings.cancel'))),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _logout();
                                },
                                child: Text(context.tr('settings.delete_account'), style: const TextStyle(color: FxColors.error)),
                              ),
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
