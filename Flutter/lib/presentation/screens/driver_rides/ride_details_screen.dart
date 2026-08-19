/* 

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/helper/share_helper.dart';
import 'package:a_tareqaak/core/l10n/app_localizations.dart';
import 'package:a_tareqaak/core/resources/app_colors.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:a_tareqaak/presentation/bloc/rides/ride_details/i_ride_details_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/ride_details/i_ride_details_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/ride_details/ride_details_bloc.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart' show SectionTitle;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class RideDetailsScreen extends StatelessWidget {
  final RideDataModel ride;
  
  const RideDetailsScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RideDetailsBloc()..add(GetRideDetailsEvent(IdEntity(ride.id!))),
      child: const _RideDetailsContent(),
    );
  }
}

class _RideDetailsContent extends StatelessWidget {
  const _RideDetailsContent();

  // بناء نص مشاركة الرحلة وإرساله عبر share_plus
  void _shareRide(BuildContext context, AppLocalizations tr, RideDataModel? ride) {
    if (ride == null) return;

    final buffer = StringBuffer()
      ..writeln(tr.ride_details_title)
      ..writeln('${tr.departure_location}: ${ride.location ?? ''}')
      ..writeln('${tr.destination}: ${ride.destination ?? ''}')
      ..writeln(
          '${tr.date_and_time}: ${ride.departureDate ?? ''} ${ride.departureTime ?? ''}')
      ..writeln('${tr.driver}: ${ride.driverInfo?.driverName ?? ''}')
      ..writeln('${tr.price}: ${ride.cost ?? ''} ${tr.syrian_pound}');

    ShareHelper.shareText(
      buffer.toString().trim(),
      subject: tr.share_ride,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: SafeArea(
        child: BlocBuilder<RideDetailsBloc, IRideDetailsState>(
          builder: (context, state) {
            if (state is RideDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RideDetailsFailed) {
              return Center(child: BodyTitle(text: state.message));
            }
            if (state is RideDetailsLoaded) {
              final ride = state.response?.data?.ride;
              final driverInfo = ride?.driverInfo;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPaddingWidth.p20,
                  vertical: AppPaddingHeight.p15,
                ),
                child: Column(
                  spacing: AppHeight.h16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: FaIcon(
                            isRtl
                                ? FontAwesomeIcons.chevronRight
                                : FontAwesomeIcons.chevronLeft,
                            color: AppColors.blackText,
                            size: AppSize.s20,
                          ),
                        ),
                        SectionTitle(
                          text: tr.ride_details_title,
                          fontSize: AppFontSize.s18,
                          fontWeight: AppFontWeight.bold,
                        ),
                        SizedBox(width: AppWidth.w40),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.all(AppPaddingWidth.p16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SectionTitle(
                            text: ride?.location ?? '',
                            fontSize: AppFontSize.s16,
                            color: AppColors.primary,
                          ),
                          FaIcon(
                            FontAwesomeIcons.arrowRightLong,
                            color: AppColors.primary,
                            size: AppSize.s20,
                          ),
                          SectionTitle(
                            text: ride?.destination ?? '',
                            fontSize: AppFontSize.s16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.all(AppPaddingWidth.p14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                        border: Border.all(color: AppColors.lightGreySec),
                      ),
                      child: Row(
                        spacing: AppWidth.w12,
                        children: [
                          CircleAvatar(
                            radius: AppRadius.r25,
                            backgroundColor: AppColors.lightGrey,
                            child: FaIcon(
                              FontAwesomeIcons.user,
                              color: AppColors.primary,
                              size: AppSize.s24,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              spacing: AppHeight.h4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionTitle(
                                  text: driverInfo?.driverName ?? tr.driver,
                                  fontSize: AppFontSize.s15,
                                ),
                                BodyTitle(
                                  text:
                                      '${ride?.departureDate ?? ''} | ${ride?.departureTime ?? ''}',
                                  fontSize: AppFontSize.s12,
                                  color: AppColors.greyText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: AppColors.primary,
                      onPressed: () => _shareRide(context, tr, ride),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppWidth.w8,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.shareNodes,
                            color: AppColors.white,
                            size: AppSize.s18,
                          ),
                          BodyTitle(
                            text: tr.share_ride,
                            color: AppColors.white,
                            fontSize: AppFontSize.s16,
                            fontWeight: AppFontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
 */

import 'package:a_tareqaak/presentation/cubit/profile/driver_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/helper/share_helper.dart';
import 'package:a_tareqaak/core/l10n/app_localizations.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:a_tareqaak/presentation/bloc/rides/ride_details/i_ride_details_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/ride_details/i_ride_details_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/ride_details/ride_details_bloc.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class RideDetailsScreen extends StatelessWidget {
  final RideDataModel ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RideDetailsBloc()..add(GetRideDetailsEvent(IdEntity(ride.id!))),
      child: _RideDetailsContent(initialRide: ride),
    );
  }
}

class _RideDetailsContent extends StatelessWidget {
  final RideDataModel initialRide;

  const _RideDetailsContent({required this.initialRide});

  void _shareRide(BuildContext context, AppLocalizations tr, RideDataModel? ride) {
    if (ride == null) return;
    final buffer = StringBuffer()
      ..writeln(tr.ride_details_title)
      ..writeln('${tr.departure_location}: ${ride.location ?? ''}')
      ..writeln('${tr.destination}: ${ride.destination ?? ''}')
      ..writeln('${tr.date_and_time}: ${ride.departureDate ?? ''} ${ride.departureTime ?? ''}')
      ..writeln('${tr.driver}: ${ride.driverInfo?.driverName ?? ''}')
      ..writeln('${tr.price}: ${ride.cost ?? ''} ${tr.syrian_pound}');

    ShareHelper.shareText(
      buffer.toString().trim(),
      subject: tr.share_ride,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocBuilder<RideDetailsBloc, IRideDetailsState>(
          builder: (context, state) {
            if (state is RideDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RideDetailsFailed) {
              return Center(child: BodyTitle(text: state.message));
            }
            if (state is RideDetailsLoaded) {
              final ride = state.response?.data?.ride ?? initialRide;
              final driverInfo = ride.driverInfo;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPaddingWidth.p20,
                  vertical: AppPaddingHeight.p15,
                ),
                child: Column(
                  spacing: AppHeight.h16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: FaIcon(
                            isRtl ? FontAwesomeIcons.chevronRight : FontAwesomeIcons.chevronLeft,
                            color: context.appColors.blackText,
                            size: AppSize.s20,
                          ),
                        ),
                        SectionTitle(
                          text: tr.ride_details_title,
                          fontSize: AppFontSize.s18,
                          fontWeight: AppFontWeight.bold,
                        ),
                        SizedBox(width: AppWidth.w40),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.all(AppPaddingWidth.p16),
                      decoration: BoxDecoration(
                        color: context.appColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.primary.withOpacity(0.08),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SectionTitle(
                            text: ride.location ?? '',
                            fontSize: AppFontSize.s16,
                            color: context.appColors.primary,
                          ),
                          FaIcon(
                            FontAwesomeIcons.arrowRightLong,
                            color: context.appColors.primary,
                            size: AppSize.s20,
                          ),
                          SectionTitle(
                            text: ride.destination ?? '',
                            fontSize: AppFontSize.s16,
                            color: context.appColors.primary,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.all(AppPaddingWidth.p14),
                      decoration: BoxDecoration(
                        color: context.appColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                        border: Border.all(color: context.appColors.lightGreySec),
                      ),
                      child: Row(
                        spacing: AppWidth.w12,
                        children: [
                          CircleAvatar(
                            radius: AppRadius.r25,
                            backgroundColor: context.appColors.lightGrey,
                            child: FaIcon(
                              FontAwesomeIcons.user,
                              color: context.appColors.primary,
                              size: AppSize.s24,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              spacing: AppHeight.h4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionTitle(
                                  text: driverInfo?.driverName ?? tr.driver,
                                  fontSize: AppFontSize.s15,
                                ),
                                BodyTitle(
                                  text: '${ride.departureDate ?? ''} | ${ride.departureTime ?? ''}',
                                  fontSize: AppFontSize.s12,
                                  color: context.appColors.greyText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // زر تتبع مسار الرحلة المباشر للراكب
                    if(context.read<DriverProfileCubit>().isRider)
                    CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      onPressed: () {
                        RideTrackingRoute($extra: ride, isDriver: false).push(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppWidth.w8,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationCrosshairs,
                            color: context.appColors.white,
                            size: AppSize.s18,
                          ),
                          BodyTitle(
                            text: "تتبع مسار الرحلة مباشرة",
                            color: context.appColors.white,
                            fontSize: AppFontSize.s16,
                            fontWeight: AppFontWeight.bold,
                          ),
                        ],
                      ),
                    ),

                    // زر مشاركة الرحلة
                    CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      onPressed: () => _shareRide(context, tr, ride),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppWidth.w8,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.shareNodes,
                            color: context.appColors.white,
                            size: AppSize.s18,
                          ),
                          BodyTitle(
                            text: tr.share_ride,
                            color: context.appColors.white,
                            fontSize: AppFontSize.s16,
                            fontWeight: AppFontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}