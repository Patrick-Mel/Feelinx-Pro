import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';

class FeelinxApp extends StatelessWidget {
  const FeelinxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Feelinx',
      debugShowCheckedModeBanner: false,
      theme: FxTheme.lightTheme,
      darkTheme: FxTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode first class experience
      routerConfig: appRouter,
    );
  }
}
