from rest_framework import serializers
from .models import DeviceToken, Notification


class NotificationSerializer(serializers.ModelSerializer):

    class Meta:
        model = Notification
        fields = [
            "id",
            "title",
            "body",
            "notification_type",
            "data",
            "is_read",
            "created_at",
        ]


class DeviceTokenSerializer(serializers.ModelSerializer):

    class Meta:
        model = DeviceToken
        fields = ["token"]

    def validate_token(self, value):

        if not value:
            raise serializers.ValidationError(
                "Device token is required."
            )

        return value