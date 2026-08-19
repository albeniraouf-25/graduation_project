import 'package:a_tareqaak/core/exceptions/app_exception.dart';
import 'package:a_tareqaak/data/data_source/notifications/notifications_remote_data_source.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/notifications/notification_model.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:a_tareqaak/domain/repository/notifications/i_notifications_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: INotificationsRepository)
class NotificationsRepository implements INotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepository(this._remoteDataSource);

  @override
  Future<Either<AppException, BaseModel<NotificationsListModel>?>>
      getNotifications() =>
          _remoteDataSource.getNotifications();

  @override
  Future<Either<AppException, BaseModel<dynamic>?>> markAsRead(IdEntity data) =>
      _remoteDataSource.markAsRead(data);

  @override
  Future<Either<AppException, BaseModel<dynamic>?>> markAllRead() =>
      _remoteDataSource.markAllRead();
}
