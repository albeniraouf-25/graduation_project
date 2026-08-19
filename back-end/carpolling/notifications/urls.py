from django.urls import path
from .views import (
    RegisterDeviceTokenView,
    NotificationListView,
    MarkNotificationReadView,
    MarkAllNotificationsReadView,
)


urlpatterns = [

    path("register-device/", RegisterDeviceTokenView.as_view(), name="register-device"),
    path("", NotificationListView.as_view(), name="notifications-list"),
    path("<int:notification_id>/read/", MarkNotificationReadView.as_view(), name="notification-read"),
    path("read-all/", MarkAllNotificationsReadView.as_view(), name="notifications-read-all"),

]