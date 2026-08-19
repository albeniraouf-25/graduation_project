import 'package:a_tareqaak/core/exceptions/app_exception.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/notifications/notification_model.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:dartz/dartz.dart';

// واجهة مستودع الإشعارات
abstract interface class INotificationsRepository {
  Future<Either<AppException, BaseModel<NotificationsListModel>?>>
      getNotifications();
  Future<Either<AppException, BaseModel<dynamic>?>> markAsRead(IdEntity data);
  Future<Either<AppException, BaseModel<dynamic>?>> markAllRead();
}
