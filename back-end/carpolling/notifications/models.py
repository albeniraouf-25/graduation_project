from django.db import models
from users.models import MainUser


class DeviceToken(models.Model):

    user = models.ForeignKey(
        MainUser,
        on_delete=models.CASCADE,
        related_name="device_tokens"
    )

    token = models.CharField(max_length=500, unique=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-updated_at"]

    def __str__(self):
        return f"{self.user.email} - {self.token[:20]}"


class Notification(models.Model):

    user = models.ForeignKey(
        MainUser,
        on_delete=models.CASCADE,
        related_name="notifications"
    )

    title = models.CharField(max_length=255)
    body = models.TextField(blank=True, default="")

    # نوع الإشعار (مثل: reservation, payment, ride ...) اختياري
    notification_type = models.CharField(max_length=50, blank=True, default="")

    # بيانات إضافية مرافقة للإشعار (نفس data الخاصة بـ FCM)
    data = models.JSONField(blank=True, null=True)

    is_read = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.user.email} - {self.title[:30]}"