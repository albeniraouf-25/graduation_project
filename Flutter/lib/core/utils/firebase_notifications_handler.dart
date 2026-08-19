import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:a_tareqaak/core/constants/api_endpoints.dart';
import 'package:a_tareqaak/core/helper/network_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void notificationTapBackground(NotificationResponse notificationResponse) {
  if (kDebugMode) {
    print('Notification tapped in background: ${notificationResponse.payload}');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling background message: ${message.messageId}");
  }
}

class FirebaseNotificationsHandler {
  static final FirebaseNotificationsHandler _instance = FirebaseNotificationsHandler._internal();

  factory FirebaseNotificationsHandler() => _instance;

  FirebaseNotificationsHandler._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  RemoteMessage? newMessage;

  static const int _apnsTokenRetryCount = 5;
  static const Duration _apnsRetryDelay = Duration(milliseconds: 400);
  static const Duration _interactiveTokenTimeout = Duration(milliseconds: 1200);

  String? _cachedFcmToken;

  String? get cachedFcmToken => _cachedFcmToken;

  void warmUpFcmToken() {
    if (_cachedFcmToken != null) return;

    unawaited(
      _safeGetFcmToken().then((token) {
        if (token != null) {
          _cachedFcmToken = token;
          print("_cachedFcmToken: $_cachedFcmToken");
          _registerToken(token);
        }
      }),
    );
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _setupNotificationChannels();

    var android = const AndroidInitializationSettings('@mipmap/launcher_icon');
    var ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    _flutterLocalNotificationsPlugin.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    warmUpFcmToken();

    _firebaseMessaging.onTokenRefresh.listen((token) {
      _cachedFcmToken = token;
      _registerToken(token);
    });
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessageEvent);
    FirebaseMessaging.onMessage.listen((m) {
      _handleForegroundMessage(m);
      _handleForegroundMessageEvent(m);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
  }

  Future<void> _setupNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'notification_channel', // قناة افتراضية
          'Default Notifications',
          description: 'General notifications',
          importance: Importance.high,
        ),
      );

      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'alert_channel', // قناة خاصة بالتنبيهات
          'Alert Notifications',
          description: 'Urgent alert notifications',
          importance: Importance.max,
        ),
      );

      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'custom_channel', // قناة أخرى مخصصة
          'Custom Notifications',
          description: 'Custom notifications with different sounds',
          importance: Importance.max,
        ),
      );
    }
  }

  Future<String?> refreshFcmToken() async {
    if (_cachedFcmToken != null) {
      return _cachedFcmToken;
    }

    String? currentToken = await _safeGetFcmToken(timeout: _interactiveTokenTimeout);
    if (kDebugMode) print('FCM Token: $currentToken');
    _cachedFcmToken = currentToken ?? _cachedFcmToken;

    if (currentToken == null) {
      _safeGetFcmToken().then((token) {
        if (token != null) {
          _cachedFcmToken = token;
          _registerToken(token);
        }
      });
    }

    return currentToken;
  }

  Future<String?> _safeGetFcmToken({Duration? timeout}) async {
    if (Platform.isIOS) {
      final DateTime start = DateTime.now();
      for (int retry = 0; retry < _apnsTokenRetryCount; retry++) {
        final String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          break;
        }

        if (kDebugMode) {
          print('APNS token is not ready yet (attempt ${retry + 1}/$_apnsTokenRetryCount).');
        }

        if (timeout != null && DateTime.now().difference(start) + _apnsRetryDelay > timeout) {
          if (kDebugMode) {
            print('Skipping APNS wait because timeout was reached.');
          }
          break;
        }

        await Future.delayed(_apnsRetryDelay);
      }
    }

    try {
      return timeout == null
          ? await _firebaseMessaging.getToken()
          : await _firebaseMessaging.getToken().timeout(timeout);
    } on TimeoutException {
      if (kDebugMode) {
        print('Timed out while fetching FCM token, will retry in background.');
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
        if (kDebugMode) {
          print('Unable to get FCM token yet because APNS token is not set.');
        }
        return null;
      }
      rethrow;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground notification: ${message.notification?.title}');
    }

    newMessage = message;
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    AppleNotification? ios = message.notification?.apple;

    if (notification != null) {
      // القناة الافتراضية يجب أن تطابق قناة أنشأناها فعلاً في _setupNotificationChannels
      String channelId = message.notification?.android?.channelId ?? 'notification_channel';
      _flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(channelId, 'Dynamic Notifications', icon: '@mipmap/launcher_icon'),
          iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  void _handleForegroundMessageEvent(RemoteMessage message) {
    if (kDebugMode) {
      print('Processing foreground message: ${message.messageId}');
    }
  }

  void _handleOpenedMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification opened from background: ${message.data}');
    }
    newMessage = message;
  }

  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      if (kDebugMode) {
        print("App opened from terminated state via notification: ${message.data}");
      }
      newMessage = message;
    }
  }

  Future<void> _onNotificationTap(NotificationResponse? response) async {
    if (newMessage != null) {}
  }

  /// يرسل رمز FCM إلى الخادم لتسجيل الجهاز.
  /// يُسجّل فقط عندما يكون المستخدم مسجّل الدخول (يوجد رمز وصول)،
  /// لتفادي إطلاق تدفّق انتهاء الجلسة على استجابة 401.
  Future<void> _registerToken(String token) async {
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    if (token.isEmpty) return;

    try {
      final networkHelper = NetworkHelper();
      final authToken = await networkHelper.getToken();
      // بدون تسجيل دخول لا يمكن ربط الجهاز بالمستخدم — نؤجّل حتى تسجيل الدخول
      if (authToken == null || authToken.isEmpty) {
        if (kDebugMode) {
          print('Skipping device token registration: user not authenticated.');
        }
        return;
      }

      await networkHelper.post(
        '${ApiEndpoints.notifications}${ApiEndpoints.registerDevice}',
        data: {'token': token},
        isFormDate: false,
      );

      if (kDebugMode) {
        print('Device token registered with backend.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to register device token: $e');
      }
    }
  }

  /// يُستدعى بعد تسجيل الدخول لضمان تسجيل رمز الجهاز الحالي بالخادم.
  Future<void> registerTokenAfterLogin() async {
    final token = _cachedFcmToken ?? await _safeGetFcmToken();
    if (token != null) {
      _cachedFcmToken = token;
      await _registerToken(token);
    }
  }
}
