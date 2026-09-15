import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';

const _storage = FlutterSecureStorage();

// --- Theme Provider ---
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await _storage.read(key: 'app_theme_mode');
      if (savedTheme == 'light') {
        state = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        state = ThemeMode.dark;
      }
    } catch (_) {}
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      await _storage.write(
        key: 'app_theme_mode',
        value: mode == ThemeMode.light ? 'light' : 'dark',
      );
    } catch (_) {}
  }

  Future<void> toggleTheme(bool isDark) async {
    await setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// --- Locale Provider ---
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final savedLang = await _storage.read(key: 'app_locale');
      if (savedLang == 'en') {
        state = const Locale('en');
      } else if (savedLang == 'fr') {
        state = const Locale('fr');
      }
    } catch (_) {}
  }

  Future<void> setLocale(String langCode, BuildContext context) async {
    final newLocale = Locale(langCode);
    state = newLocale;
    await context.setLocale(newLocale);
    try {
      await _storage.write(key: 'app_locale', value: langCode);
    } catch (_) {}
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
