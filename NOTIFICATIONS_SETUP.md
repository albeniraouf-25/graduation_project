# Push Notifications (FCM) — Setup Checklist

The notification **code** is now fully wired on both the Flutter app and the
Django backend. To make notifications actually deliver, you must add the
Firebase credential files below — these are project-specific secrets that
cannot be generated from source and are (correctly) git-ignored.

Until they are added, the app and server run normally; notifications are simply
skipped (Firebase init is guarded on both sides).

## 1. Flutter app

Run FlutterFire configure against your Firebase project. From `Flutter/`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This regenerates:

- `Flutter/lib/core/utils/firebase_options.dart` — currently stubbed/commented
  out and pointing at an old project (`qwafil`). `flutterfire configure`
  overwrites it with valid values for the real app.
- `Flutter/android/app/google-services.json` — **missing**, required for
  Android FCM.
- (iOS) `GoogleService-Info.plist` under `ios/Runner/`.

### Android Gradle

After `google-services.json` exists, apply the Google Services plugin. In
`Flutter/android/app/build.gradle.kts` add to the `plugins { }` block:

```kotlin
id("com.google.gms.google-services")
```

(The plugin is already declared with `apply false` in
`android/settings.gradle.kts`.) The build will fail if the plugin is applied
without `google-services.json`, which is why it is left un-applied for now.

## 2. Backend (Django)

Add the Firebase Admin service-account key:

- `back-end/carpolling/firebase/serviceAccountKey.json` — **missing**. Download
  it from Firebase Console → Project Settings → Service Accounts → *Generate new
  private key*.

`firebase/firebase_config.py::init_firebase()` is called on startup from
`notifications/apps.py::ready()` and is guarded: if the key is missing it logs a
warning and disables sends instead of crashing.

## What already works in code (no action needed)

- App: `AppServices.init()` initializes Firebase + `FirebaseNotificationsHandler`
  (guarded), requests notification permission, creates Android channels, shows
  foreground notifications via `flutter_local_notifications`, warms up the FCM
  token, and registers it with the backend after login and on token refresh.
- App: `POST /api/notifications/register-device/` is called with the FCM token
  (only while authenticated).
- Backend: `notifications` URLs are mounted, `RegisterDeviceTokenView` stores
  `DeviceToken`s, and ride/payment events already call `safe_send_notification`.
- Android: `POST_NOTIFICATIONS` permission and the default FCM channel
  (`notification_channel`) are declared in `AndroidManifest.xml`.
