import 'package:a_tareqaak/domain/entity/rides/rides_no_params_entity.dart';
import 'package:equatable/equatable.dart';

sealed class IMyReservationsEvent extends Equatable {
  const IMyReservationsEvent();
}

final class GetMyReservationsEvent extends IMyReservationsEvent {
  final RidesNoParamsEntity entity;

  const GetMyReservationsEvent({this.entity = const RidesNoParamsEntity()});

  @override
  List<Object?> get props => [entity];
}
