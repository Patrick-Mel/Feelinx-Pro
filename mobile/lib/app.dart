import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/app_settings_provider.dart';

class FeelinxApp extends ConsumerWidget {
  const FeelinxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Feelinx',
      debugShowCheckedModeBanner: false,
      theme: FxTheme.lightTheme,
      darkTheme: FxTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: appRouter,
    );
  }
}
