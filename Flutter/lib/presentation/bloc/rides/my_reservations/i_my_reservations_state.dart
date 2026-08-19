import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/rides/reservation_data_model.dart';
import 'package:equatable/equatable.dart';

sealed class IMyReservationsState extends Equatable {
  const IMyReservationsState();
}

final class MyReservationsInitial extends IMyReservationsState {
  @override
  List<Object> get props => [];
}

final class MyReservationsLoading extends IMyReservationsState {
  @override
  List<Object> get props => [];
}

final class MyReservationsLoaded extends IMyReservationsState {
  final BaseModel<ReservationsListModel>? response;

  const MyReservationsLoaded({required this.response});

  @override
  List<Object?> get props => [response];
}

final class MyReservationsFailed extends IMyReservationsState {
  final String message;

  const MyReservationsFailed(this.message);

  @override
  List<Object> get props => [message];
}
