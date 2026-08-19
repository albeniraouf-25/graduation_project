from django.apps import AppConfig


class NotificationsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'notifications'

    def ready(self):
        # تهيئة Firebase Admin عند إقلاع التطبيق (محميّة داخلياً ضد غياب المفتاح)
        try:
            from firebase.firebase_config import init_firebase
            init_firebase()
        except Exception:  # noqa: BLE001
            # لا نمنع إقلاع الخادم إذا فشلت تهيئة Firebase
            pass
