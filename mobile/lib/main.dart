import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Instantly remove native Android/iOS splash screen to transition to Flutter UI
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: FeelinxApp(),
    ),
  );
}
