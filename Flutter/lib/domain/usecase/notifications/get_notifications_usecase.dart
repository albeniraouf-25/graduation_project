import 'package:a_tareqaak/core/exceptions/app_exception.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/notifications/notification_model.dart';
import 'package:a_tareqaak/domain/entity/rides/rides_no_params_entity.dart';
import 'package:a_tareqaak/domain/repository/notifications/i_notifications_repository.dart';
import 'package:a_tareqaak/domain/usecase/i_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@Injectable(
    as: IUseCase<BaseModel<NotificationsListModel>?, RidesNoParamsEntity>)
@Named('GetNotificationsUseCase')
class GetNotificationsUseCase
    implements
        IUseCase<BaseModel<NotificationsListModel>?, RidesNoParamsEntity> {
  final INotificationsRepository _repository;

  GetNotificationsUseCase(this._repository);

  @override
  Future<Either<AppException, BaseModel<NotificationsListModel>?>> call(
          RidesNoParamsEntity data) =>
      _repository.getNotifications();
}
