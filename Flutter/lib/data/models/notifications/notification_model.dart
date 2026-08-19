import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

// نموذج الإشعار القادم من الخادم
@JsonSerializable(createToJson: false)
class NotificationModel extends Equatable {
  final int? id;
  final String? title;
  final String? body;
  @JsonKey(name: 'notification_type')
  final String? notificationType;
  final Map<String, dynamic>? data;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const NotificationModel({
    this.id,
    this.title,
    this.body,
    this.notificationType,
    this.data,
    this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  @override
  List<Object?> get props =>
      [id, title, body, notificationType, data, isRead, createdAt];
}

// غلاف قائمة الإشعارات — الاستجابة {"notifications": [...], "unread_count": N}
@JsonSerializable(createToJson: false)
class NotificationsListModel extends Equatable {
  final List<NotificationModel>? notifications;
  @JsonKey(name: 'unread_count')
  final int? unreadCount;

  const NotificationsListModel({this.notifications, this.unreadCount});

  factory NotificationsListModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationsListModelFromJson(json);

  @override
  List<Object?> get props => [notifications, unreadCount];
}
