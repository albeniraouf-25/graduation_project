import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/data/models/rides/reservation_data_model.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:a_tareqaak/presentation/bloc/rides/cancel_reservation/cancel_reservation_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/rides/cancel_reservation/i_cancel_reservation_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/cancel_reservation/i_cancel_reservation_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_reservations/i_my_reservations_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_reservations/i_my_reservations_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_reservations/my_reservations_bloc.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// شاشة حجوزات الراكب — تعرض الحجوزات التي أنشأها الراكب مع إمكانية الإلغاء
class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              MyReservationsBloc()..add(const GetMyReservationsEvent()),
        ),
        BlocProvider(create: (_) => CancelReservationBloc()),
      ],
      child: const _MyReservationsContent(),
    );
  }
}

class _MyReservationsContent extends StatelessWidget {
  const _MyReservationsContent();

  void _refresh(BuildContext context) {
    context
        .read<MyReservationsBloc>()
        .add(const GetMyReservationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocListener<CancelReservationBloc, ICancelReservationState>(
          listener: (context, state) {
            if (state is CancelReservationLoaded) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: state.resultModel?.message ?? tr.success_title,
                contentType: ContentType.success,
              );
              _refresh(context);
            } else if (state is CancelReservationFailed) {
              showCustomSnackBar(
                context: context,
                title: tr.error_title,
                message: state.message,
                contentType: ContentType.failure,
              );
            }
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPaddingWidth.p20,
                  vertical: AppPaddingHeight.p15,
                ),
                child: Center(
                  child: SectionTitle(
                    text: tr.my_reservations,
                    fontSize: AppFontSize.s18,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<MyReservationsBloc, IMyReservationsState>(
                  builder: (context, state) {
                    if (state is MyReservationsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is MyReservationsFailed) {
                      return Center(child: BodyTitle(text: state.message));
                    }

                    final reservations = state is MyReservationsLoaded
                        ? state.response?.data?.reservations ??
                            <ReservationDataModel>[]
                        : <ReservationDataModel>[];

                    if (reservations.isEmpty) {
                      return Center(child: BodyTitle(text: tr.no_data));
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _refresh(context),
                      child: ListView.separated(
                        padding: EdgeInsets.all(AppPaddingWidth.p20),
                        itemCount: reservations.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppHeight.h12),
                        itemBuilder: (context, index) => _ReservationCard(
                          reservation: reservations[index],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationDataModel reservation;

  const _ReservationCard({required this.reservation});

  bool get _isCancelable {
    final status = reservation.status?.toLowerCase();
    return status == 'pending' || status == 'accepted';
  }

  Color _statusColor(BuildContext context) {
    switch (reservation.status?.toLowerCase()) {
      case 'accepted':
        return context.appColors.darkGreen;
      case 'rejected':
      case 'cancelled':
        return context.appColors.red;
      default:
        return context.appColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final from = reservation.rideLocation ?? '';
    final to = reservation.rideDestination ?? '';
    final title = [from, to].where((e) => e.isNotEmpty).join(' → ');

    return Container(
      padding: EdgeInsets.all(AppPaddingWidth.p16),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: AppHeight.h10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SectionTitle(
                  text: title.isNotEmpty ? title : tr.destination,
                  fontSize: AppFontSize.s16,
                ),
              ),
              if ((reservation.status ?? '').isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPaddingWidth.p8,
                    vertical: AppPaddingHeight.p4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.r6),
                  ),
                  child: BodyTitle(
                    text: reservation.status!,
                    fontSize: AppFontSize.s12,
                    color: _statusColor(context),
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
            ],
          ),
          if ((reservation.pickupLocation ?? '').isNotEmpty)
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: AppSize.s14,
                  color: context.appColors.greyText,
                ),
                SizedBox(width: AppWidth.w6),
                Expanded(
                  child: BodyTitle(
                    text: reservation.pickupLocation!,
                    fontSize: AppFontSize.s13,
                    color: context.appColors.greyText,
                  ),
                ),
              ],
            ),
          if ((reservation.payment ?? '').isNotEmpty)
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.moneyBill,
                  size: AppSize.s14,
                  color: context.appColors.greyText,
                ),
                SizedBox(width: AppWidth.w6),
                BodyTitle(
                  text: reservation.payment!,
                  fontSize: AppFontSize.s13,
                  color: context.appColors.greyText,
                ),
              ],
            ),
          if (_isCancelable)
            BlocBuilder<CancelReservationBloc, ICancelReservationState>(
              builder: (context, state) {
                final isLoading = state is CancelReservationLoading;
                return CustomElevatedButton(
                  height: AppHeight.h40,
                  borderRadius: AppRadius.r10,
                  color: context.appColors.lightRed,
                  borderSide: BorderSide(color: context.appColors.red),
                  notEnable: isLoading || reservation.id == null,
                  loading: isLoading,
                  onPressed: () {
                    if (isLoading || reservation.id == null) return;
                    context.read<CancelReservationBloc>().add(
                          CancelReservationEvent(
                            IdEntity(reservation.id!),
                          ),
                        );
                  },
                  child: BodyTitle(
                    text: tr.cancel,
                    color: context.appColors.red,
                    fontSize: AppFontSize.s13,
                    fontWeight: AppFontWeight.bold,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
