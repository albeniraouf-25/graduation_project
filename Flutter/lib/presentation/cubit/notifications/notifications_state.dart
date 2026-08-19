// lib/presentation/cubit/notifications/notifications_state.dart
import 'package:a_tareqaak/data/models/notifications/notification_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class NotificationsState {}

class NotificationsInitialState extends NotificationsState {}

class NotificationsLoadingState extends NotificationsState {}

class NotificationsLoadedState extends NotificationsState {
  final List<NotificationModel> notifications; // القائمة الكاملة
  final int selectedTab; // 0: الكل، 1: غير المقروءة
  final int unreadCount;

  NotificationsLoadedState({
    required this.notifications,
    required this.selectedTab,
    required this.unreadCount,
  });
}

class NotificationsErrorState extends NotificationsState {
  final String message;
  NotificationsErrorState(this.message);
}
