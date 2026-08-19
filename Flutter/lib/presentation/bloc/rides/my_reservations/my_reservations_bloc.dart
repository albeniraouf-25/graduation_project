import 'dart:async';
import 'dart:developer';

import 'package:a_tareqaak/core/services/locator/locator.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/rides/reservation_data_model.dart';
import 'package:a_tareqaak/domain/entity/rides/rides_no_params_entity.dart';
import 'package:a_tareqaak/domain/usecase/i_use_case.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_reservations/i_my_reservations_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_reservations/i_my_reservations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// بلوك جلب حجوزات الراكب (GET /rides/my_reservations/)
class MyReservationsBloc
    extends Bloc<IMyReservationsEvent, IMyReservationsState> {
  MyReservationsBloc() : super(MyReservationsInitial()) {
    on<GetMyReservationsEvent>(_onGetMyReservations);
  }

  FutureOr<void> _onGetMyReservations(
    GetMyReservationsEvent event,
    Emitter<IMyReservationsState> emit,
  ) async {
    emit(MyReservationsLoading());
    try {
      final result = await locator<
          IUseCase<BaseModel<ReservationsListModel>?, RidesNoParamsEntity>>(
        instanceName: 'MyReservationsUseCase',
      )(event.entity);

      result.fold(
        (failure) => emit(MyReservationsFailed(failure.message)),
        (response) => emit(MyReservationsLoaded(response: response)),
      );
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      emit(MyReservationsFailed(e.toString()));
    }
  }
}
