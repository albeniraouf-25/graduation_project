from firebase_admin import messaging

from .models import DeviceToken, Notification


def send_notification_to_token(
    token,
    title,
    body,
    data=None
):

    message = messaging.Message(

        notification=messaging.Notification(
            title=title,
            body=body
        ),

        data=data or {},

        token=token
    )

    return messaging.send(message)

def send_notification_to_user(
    user,
    title,
    body,
    data=None
):

    # حفظ الإشعار في قاعدة البيانات ليظهر في شاشة الإشعارات داخل التطبيق
    try:
        Notification.objects.create(
            user=user,
            title=title or "",
            body=body or "",
            notification_type=(data or {}).get("type", "") if isinstance(data, dict) else "",
            data=data if isinstance(data, dict) else None,
        )
    except Exception as e:  # noqa: BLE001
        print(f"Failed to persist notification: {e}")

    device_tokens = DeviceToken.objects.filter(
        user=user
    )

    responses = []

    for device_token in device_tokens:

        try:

            response = send_notification_to_token(
                token=device_token.token,
                title=title,
                body=body,
                data=data
            )

            responses.append(response)

        except Exception as e:

            print(
                f"Notification failed: {e}"
            )

    return responses

def send_notification_to_users(
    users,
    title,
    body,
    data=None
):

    for user in users:

        send_notification_to_user(
            user=user,
            title=title,
            body=body,
            data=data
        )


import logging

logger = logging.getLogger(__name__)


def safe_send_notification(
    user,
    title,
    body,
    data=None
):

    try:

        return send_notification_to_user(
            user=user,
            title=title,
            body=body,
            data=data
        )

    except Exception as e:

        logger.exception(
            "Failed to send notification: %s",
            e
        )

        return None