from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from .models import DeviceToken, Notification
from .serializers import DeviceTokenSerializer, NotificationSerializer


class RegisterDeviceTokenView(APIView):

    def post(self, request):

        serializer = DeviceTokenSerializer(data=request.data)

        if serializer.is_valid():

            token = serializer.validated_data["token"]

            device_token, created = DeviceToken.objects.update_or_create(
                token=token,
                defaults={
                    "user": request.user
                }
            )

            return Response(
                {
                    "message": "Device token registered successfully.",
                    "token_id": device_token.id
                },
                status=status.HTTP_200_OK
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


class NotificationListView(APIView):
    """يرجع إشعارات المستخدم الحالي. يدعم ?unread=true لتصفية غير المقروءة."""

    def get(self, request):
        notifications = Notification.objects.filter(user=request.user)

        unread_only = request.query_params.get("unread")
        if unread_only in ("true", "1", "True"):
            notifications = notifications.filter(is_read=False)

        serializer = NotificationSerializer(notifications, many=True)
        unread_count = Notification.objects.filter(
            user=request.user, is_read=False
        ).count()

        return Response(
            {
                "notifications": serializer.data,
                "unread_count": unread_count,
            },
            status=status.HTTP_200_OK,
        )


class MarkNotificationReadView(APIView):
    """يعلّم إشعاراً واحداً كمقروء."""

    def post(self, request, notification_id):
        try:
            notification = Notification.objects.get(
                id=notification_id, user=request.user
            )
        except Notification.DoesNotExist:
            return Response(
                {"error": "Notification not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        notification.is_read = True
        notification.save(update_fields=["is_read"])

        return Response(
            {"message": "Notification marked as read."},
            status=status.HTTP_200_OK,
        )


class MarkAllNotificationsReadView(APIView):
    """يعلّم كل إشعارات المستخدم كمقروءة."""

    def post(self, request):
        updated = Notification.objects.filter(
            user=request.user, is_read=False
        ).update(is_read=True)

        return Response(
            {"message": "All notifications marked as read.", "updated": updated},
            status=status.HTTP_200_OK,
        )