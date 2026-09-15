import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'tokens.dart';
import 'typography.dart';

class FxTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FxColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: FxColors.primaryCoral,
        secondary: FxColors.secondaryIndigo,
        tertiary: FxColors.accentGold,
        surface: FxColors.darkSurface,
        error: FxColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: FxColors.darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FxColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: FxTypography.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: FxColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FxRadius.medium16),
          side: const BorderSide(color: FxColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FxColors.primaryCoral,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: FxTypography.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FxColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.medium16),
          borderSide: const BorderSide(color: FxColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.medium16),
          borderSide: const BorderSide(color: FxColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.medium16),
          borderSide: const BorderSide(color: FxColors.primaryCoral, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: FxColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: FxColors.primaryCoral,
        secondary: FxColors.secondaryIndigo,
        tertiary: FxColors.accentGold,
        surface: FxColors.lightSurface,
        error: FxColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: FxColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FxColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: FxTypography.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: FxColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FxRadius.medium16),
          side: const BorderSide(color: FxColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FxColors.primaryCoral,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: FxTypography.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FxColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.medium16),
          borderSide: const BorderSide(color: FxColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.medium16),
          borderSide: const BorderSide(color: FxColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.medium16),
          borderSide: const BorderSide(color: FxColors.primaryCoral, width: 1.5),
        ),
      ),
    );
  }
}
