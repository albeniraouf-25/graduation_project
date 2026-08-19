import 'package:a_tareqaak/core/constants/api_endpoints.dart';
import 'package:a_tareqaak/core/exceptions/app_exception.dart';
import 'package:a_tareqaak/data/data_source/base/base_remote_data_source.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/notifications/notification_model.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class NotificationsRemoteDataSource extends BaseRemoteDataSource<dynamic> {
  NotificationsRemoteDataSource() : super(ApiEndpoints.notifications);

  // جلب إشعارات المستخدم (GET /api/notifications/)
  Future<Either<AppException, BaseModel<NotificationsListModel>?>>
      getNotifications() {
    return fetchData<NotificationsListModel>(
      endpoint: ApiEndpoints.notificationsList,
      fromJsonT: (json) =>
          NotificationsListModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // تعليم إشعار كمقروء (POST /api/notifications/<id>/read/)
  Future<Either<AppException, BaseModel<dynamic>?>> markAsRead(IdEntity data) {
    return postData(
      endpoint: ApiEndpoints.notificationRead(data.id),
      isFormDate: false,
    );
  }

  // تعليم كل الإشعارات كمقروءة (POST /api/notifications/read-all/)
  Future<Either<AppException, BaseModel<dynamic>?>> markAllRead() {
    return postData(
      endpoint: ApiEndpoints.notificationsReadAll,
      isFormDate: false,
    );
  }
}
