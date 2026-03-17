import 'dart:io';
import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/app.dart';
import 'package:devalay_app/src/presentation/core/helper/deep_link_handler.dart';
import 'package:devalay_app/src/presentation/notification/service_notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
final deepLinkHandler = DeepLinkHandler();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  // Try to load from root directory (development) or assets (production)
  bool envLoaded = false;
  
  // First try loading from root directory (.env file)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ Loaded .env file from root directory');
    envLoaded = true;
  } catch (e) {
    debugPrint('⚠️ Could not load .env from root: $e');
  }
  
  // If not loaded, try loading from assets folder
  if (!envLoaded) {
    try {
      await dotenv.load(fileName: "assets/.env");
      debugPrint('✅ Loaded .env file from assets');
      envLoaded = true;
    } catch (e) {
      debugPrint('⚠️ Could not load .env from assets: $e');
    }
  }
  
  // If still not loaded, dotenv will use fallback values
  if (!envLoaded) {
    debugPrint('⚠️ No .env file found. Using fallback/default values from code.');
  }
  
  await EasyLocalization.ensureInitialized();
  
  await Firebase.initializeApp(
    options: Platform.isIOS
        ? const FirebaseOptions(
            apiKey: "AIzaSyBaYxxjsokILYrE77E0mzq5RXtZkX3DKqM",
            appId: "1:48111167046:ios:198de31b1718d1bac90c47",
            messagingSenderId: "48111167046",
            projectId: "devalay-417106",
            storageBucket: "devalay-417106.firebasestorage.app",
            iosBundleId: "com.ios.devalay",
          )
        : const FirebaseOptions(
            apiKey: "AIzaSyBMBDzUl1KqSs4daD6Qo20YuLmPg-tI6pI",
            appId: "1:48111167046:android:fb66826a2554fe84c90c47",
            messagingSenderId: "48111167046",
            projectId: "devalay-417106",
            storageBucket: "devalay-417106.firebasestorage.app",
          ),
  );
  
  if (kReleaseMode) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await configureDependencies();
  await NotificationService.initialize();
  final deepLinkHandler = DeepLinkHandler();
  await deepLinkHandler.initAppLinks();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi')],
      path: 'assets/language',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}