import 'package:a_tareqaak/core/exceptions/app_exception.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:a_tareqaak/domain/repository/notifications/i_notifications_repository.dart';
import 'package:a_tareqaak/domain/usecase/i_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: IUseCase<BaseModel<dynamic>?, IdEntity>)
@Named('MarkNotificationReadUseCase')
class MarkNotificationReadUseCase
    implements IUseCase<BaseModel<dynamic>?, IdEntity> {
  final INotificationsRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  @override
  Future<Either<AppException, BaseModel<dynamic>?>> call(IdEntity data) =>
      _repository.markAsRead(data);
}
