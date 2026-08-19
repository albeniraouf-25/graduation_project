import 'package:a_tareqaak/domain/entity/location/ride_tracking_connection_entity.dart';
import 'package:a_tareqaak/presentation/bloc/location/i_ride_tracking_event.dart';
import 'package:a_tareqaak/presentation/bloc/location/i_ride_tracking_state.dart';
import 'package:a_tareqaak/presentation/bloc/location/ride_tracking_bloc.dart';
import 'package:a_tareqaak/presentation/cubit/location/ride_tracking_cubit.dart';
import 'package:a_tareqaak/presentation/cubit/location/ride_tracking_state.dart';
import 'package:a_tareqaak/presentation/screens/ride_tracking/widgets/live_tracking_map_widget.dart';
import 'package:a_tareqaak/presentation/screens/ride_tracking/widgets/ride_tracking_info_card.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';

import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class RideTrackingScreen extends StatelessWidget {
  final RideDataModel ride;
  final bool isDriver;

  const RideTrackingScreen({
    super.key,
    required this.ride,
    this.isDriver = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RideTrackingCubit()),
        BlocProvider(
          create: (_) => RideTrackingBloc()
            ..add(
              ConnectToRideTrackingEvent(
                RideTrackingConnectionEntity(rideId: ride.id ?? 0),
              ),
            ),
        ),
      ],
      child: _RideTrackingContent(
        ride: ride,
        isDriver: isDriver,
      ),
    );
  }
}

class _RideTrackingContent extends StatelessWidget {
  final RideDataModel ride;
  final bool isDriver;

  const _RideTrackingContent({
    required this.ride,
    required this.isDriver,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return MultiBlocListener(
      listeners: [
        BlocListener<RideTrackingBloc, IRideTrackingState>(
          listener: (context, state) {
            final cubit = context.read<RideTrackingCubit>();

            if (state is RideTrackingConnected) {
              cubit.setConnected(true);
              if (isDriver) {
                cubit.startDriverGpsTracking(
                  onLocationTick: (entity) {
                    context.read<RideTrackingBloc>().add(
                          SendDriverLocationEvent(entity),
                        );
                  },
                );
              }
            } else if (state is RideTrackingLocationReceived) {
              cubit.updateDriverLocation(state.location);
            } else if (state is RideTrackingDisconnected) {
              cubit.setConnected(false);
              cubit.stopDriverGpsTracking();
            } else if (state is RideTrackingFailed) {
              showCustomSnackBar(
                context: context,
                title: tr.somethingWentWrong,
                message: state.message,
                contentType: ContentType.failure,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: context.appColors.backGround,
        body: Stack(
          children: [
            // الخريطة المباشرة مع Google Maps
            Positioned.fill(
              child: BlocBuilder<RideTrackingCubit, RideTrackingCubitState>(
                builder: (context, state) {
                  return LiveTrackingMapWidget(
                    driverPosition: state.driverPosition,
                    zoom: state.currentZoom,
                  );
                },
              ),
            ),

            // شريط العنوان العلوي وزر الرجوع
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPaddingWidth.p16,
                  vertical: AppPaddingHeight.p10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: context.appColors.white,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: FaIcon(
                          isRtl
                              ? FontAwesomeIcons.chevronRight
                              : FontAwesomeIcons.chevronLeft,
                          color: context.appColors.blackText,
                          size: AppSize.s18,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppPaddingWidth.p14,
                        vertical: AppPaddingHeight.p6,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r20),
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.primary.withOpacity(0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: SectionTitle(
                        text: "تتبع الرحلة مباشرة",
                        fontSize: AppFontSize.s15,
                        color: context.appColors.primary,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    SizedBox(width: AppWidth.w40),
                  ],
                ),
              ),
            ),

            // بطاقة تفاصيل الرحلة السفلية وحالة الاتصال
            Positioned(
              bottom: AppHeight.h20,
              left: AppWidth.w16,
              right: AppWidth.w16,
              child: BlocBuilder<RideTrackingCubit, RideTrackingCubitState>(
                builder: (context, state) {
                  return RideTrackingInfoCard(
                    ride: ride,
                    isConnected: state.isConnected,
                    lastUpdated: state.lastUpdatedTime,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}