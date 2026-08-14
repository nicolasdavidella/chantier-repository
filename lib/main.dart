import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'firebase_options.dart'; 
import 'core/connectivity/offline_banner_wrapper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

const bool useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dotenv
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found");
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (useFirebaseEmulator) {
      debugPrint('============================================');
      debugPrint('      🔥 USING FIREBASE EMULATORS 🔥       ');
      debugPrint('============================================');
      
      final localhost = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
      
      await FirebaseAuth.instance.useAuthEmulator(localhost, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(localhost, 8080);
      await FirebaseStorage.instance.useStorageEmulator(localhost, 9199);
    }
  } catch (e) {
    debugPrint('Erreur d\'initialisation Firebase (Avez-vous fait flutterfire configure ?): $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ChantierTrack',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentThemeMode,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return OfflineBannerWrapper(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
