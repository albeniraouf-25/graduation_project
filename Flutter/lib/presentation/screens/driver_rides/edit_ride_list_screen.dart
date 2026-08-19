
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_rides_driver/i_my_rides_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_rides_driver/i_my_rides_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_rides_driver/my_rides_bloc.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class EditRideListScreen extends StatelessWidget {
  const EditRideListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyRidesBloc()..add(const GetMyRidesEvent()),
      child: const _EditRideListContent(),
    );
  }
}

class _EditRideListContent extends StatefulWidget {
  const _EditRideListContent();

  @override
  State<_EditRideListContent> createState() => _EditRideListContentState();
}

class _EditRideListContentState extends State<_EditRideListContent> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPaddingWidth.p20,
                vertical: AppPaddingHeight.p15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: context.appColors.blackText,
                      size: AppSize.s20,
                    ),
                  ),
                  SectionTitle(
                    text: tr.edit_ride_title,
                    fontSize: AppFontSize.s18,
                    fontWeight: AppFontWeight.bold,
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: FaIcon(
                      isRtl
                          ? FontAwesomeIcons.chevronRight
                          : FontAwesomeIcons.chevronLeft,
                      color: context.appColors.blackText,
                      size: AppSize.s20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<MyRidesBloc, IMyRidesState>(
                builder: (context, state) {
                  if (state is MyRidesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MyRidesFailed) {
                     showCustomSnackBar(context: context, title: tr.error_title, message: state.message, contentType:  ContentType.failure);
                  }
                  final rides = state is MyRidesLoaded
                      ? state.response?.data?.rides ?? <RideDataModel>[]
                      : <RideDataModel>[];

                  if (rides.isEmpty) {
                    return Center(child: BodyTitle(text: tr.no_data));
                  }

                  return ListView.separated(
                    padding: EdgeInsets.all(AppPaddingWidth.p20),
                    itemCount: rides.length,
                    separatorBuilder: (_,_) => SizedBox(height: AppHeight.h12),
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return _buildRideItem(context, ride);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideItem(BuildContext context, RideDataModel ride) {
    final tr = context.loc;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: AppWidth.w8,
                children: [
                  SectionTitle(
                    text: ride.location ?? '',
                    fontSize: AppFontSize.s16,
                  ),
                  FaIcon(
                    FontAwesomeIcons.arrowRightLong,
                    size: AppSize.s14,
                    color: context.appColors.primary,
                  ),
                  SectionTitle(
                    text: ride.destination ?? '',
                    fontSize: AppFontSize.s16,
                  ),
                ],
              ),
              IconButton(
                onPressed: () async {
                  final updated = await context.push<bool>(
                    '/edit-ride',
                    extra: ride,
                  );
                  if (updated == true && context.mounted) {
                    context.read<MyRidesBloc>().add(const GetMyRidesEvent());
                  }
                },
                icon: CircleAvatar(
                  radius: AppRadius.r18,
                  backgroundColor: context.appColors.lightGrey,
                  child: FaIcon(
                    FontAwesomeIcons.penToSquare,
                    size: AppSize.s14,
                    color: context.appColors.blackText,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyTitle(
                text: '${ride.departureDate ?? ''} - ${ride.departureTime ?? ''}',
                fontSize: AppFontSize.s13,
                color: context.appColors.greyText,
              ),
              BodyTitle(
                text: '${ride.cost ?? ''} ${tr.syrian_pound}',
                fontSize: AppFontSize.s13,
                color: context.appColors.blackText,
                fontWeight: AppFontWeight.bold,
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: BodyTitle(
              text: '${ride.availableSeats ?? 0} ${tr.available_seats_count}',
              fontSize: AppFontSize.s13,
              color: context.appColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}