
import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';

import '../utils/firebase_notifications_handler.dart';
import '../utils/firebase_options.dart';
import 'locator/locator.dart';

class AppServices {

  static void _configureCrashlytics() {

  /* FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;


  PlatformDispatcher.instance.onError =
      (error, stack) {

    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );

    return true;
  }; */
}
  static Future<void> init() async {
    // تهيئة Hive والحاقن قبل أي شيء آخر (لا تعتمد على Firebase)
    if (!Hive.isAdapterRegistered(0)) {
      await Hive.initFlutter();
    }
    configureDependencies();

    // تهيئة Firebase والإشعارات — محميّة حتى لا يتعطّل التطبيق
    // في حال عدم توفّر ملفات إعداد Firebase (google-services.json / firebase_options).
    await _initFirebase();

    _configureCrashlytics();
  }

  static Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseNotificationsHandler().init();
    } catch (e, s) {
      // إعدادات Firebase غير متوفّرة/غير صحيحة — نُكمل تشغيل التطبيق بدون إشعارات.
      log('Firebase initialization skipped/failed: $e');
      log(s.toString());
    }
  }
}
