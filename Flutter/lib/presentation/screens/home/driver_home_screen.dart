import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_assets.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/presentation/cubit/driver_home/driver_home_cubit.dart';
import 'package:a_tareqaak/presentation/cubit/driver_home/driver_home_state.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/widgets/ride_card_widget.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/image_view.dart';
import 'package:a_tareqaak/presentation/widgets/map_widget.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverHomeCubit(),
      child: const _DriverHomeContent(),
    );
  }
}

class _DriverHomeContent extends StatelessWidget {
  const _DriverHomeContent();

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;

    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        final cubit = context.read<DriverHomeCubit>();

        return Scaffold(
          backgroundColor: context.appColors.backGround,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppPaddingWidth.p20,
                vertical: AppPaddingHeight.p15,
              ),
              child: Column(
                spacing: AppHeight.h16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الشريط العلوي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ImageView(
                        imagePath: AppAssets.logo,
                        height: AppHeight.h45,
                        fit: BoxFit.contain,
                      ),
                      Row(
                        spacing: AppWidth.w10,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: FaIcon(
                              FontAwesomeIcons.bell,
                              size: AppSize.s20,
                              color: context.appColors.blackText,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: FaIcon(
                              FontAwesomeIcons.gear,
                              size: AppSize.s20,
                              color: context.appColors.blackText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // بطاقة الموقع الحالي مع خريطة Google Maps
                  Container(
                    padding: EdgeInsets.all(AppPaddingWidth.p15),
                    decoration: BoxDecoration(
                      color: context.appColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.r16),
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.primary.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      spacing: AppHeight.h12,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              spacing: AppHeight.h4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodyTitle(
                                  text: tr.current_location,
                                  fontSize: AppFontSize.s12,
                                  color: context.appColors.greyText,
                                ),
                                SectionTitle(
                                  text: cubit.currentLocationName ?? tr.location_not_available,
                                  fontSize: AppFontSize.s14,
                                  color: context.appColors.primary,
                                ),
                              ],
                            ),
                            FaIcon(
                              FontAwesomeIcons.locationDot,
                              size: AppSize.s24,
                              color: context.appColors.primary,
                            ),
                          ],
                        ),

                        // عرض خريطة الموقع الحالي عبر Google Maps
                        if (cubit.currentLocationName != null &&
                            cubit.currentLat != null &&
                            cubit.currentLng != null)
                          MapWidget(
                            latitude: cubit.currentLat!,
                            longitude: cubit.currentLng!,
                          )
                        else
                          Container(
                            height: AppHeight.h180,
                            decoration: BoxDecoration(
                              color: context.appColors.backGround,
                              borderRadius: BorderRadius.circular(AppRadius.r16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.locationCrosshairs,
                                  size: AppSize.s35,
                                  color: context.appColors.greyText,
                                ),
                                SizedBox(height: AppHeight.h10),
                                BodyTitle(
                                  text: tr.location_not_available,
                                  fontSize: AppFontSize.s13,
                                  color: context.appColors.greyText,
                                ),
                              ],
                            ),
                          ),

                        // زر تحديث الموقع
                        CustomElevatedButton(
                          height: AppHeight.h40,
                          width: double.infinity,
                          borderRadius: AppRadius.r10,
                          color: context.appColors.primary,
                          loading: state is DriverHomeLocationLoadingState,
                          onPressed: () {
                            cubit.requestLocationAndFetch(
                              locale: Localizations.localeOf(context),
                              onGranted: () {
                                showCustomSnackBar(
                                  context: context,
                                  title: tr.success_title,
                                  message: tr.location_updated,
                                  contentType: ContentType.success,
                                );
                              },
                              onDenied: () {
                                showCustomSnackBar(
                                  context: context,
                                  title: tr.warning_title,
                                  message: tr.location_permission_denied,
                                  contentType: ContentType.warning,
                                );
                              },
                            );
                          },
                          child: BodyTitle(
                            text: tr.update_location,
                            color: context.appColors.white,
                            fontSize: AppFontSize.s14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // قسم الإجراءات السريعة
                  Column(
                    spacing: AppHeight.h10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        text: tr.quick_actions,
                        fontSize: AppFontSize.s16,
                      ),
                      Row(
                        spacing: AppWidth.w10,
                        children: [
                          _buildQuickActionCard(
                            context,
                            title: tr.publish_ride,
                            icon: FontAwesomeIcons.plus,
                            iconColor: context.appColors.primary,
                            onTap: () => PublishRideRoute().push(context),
                          ),
                          _buildQuickActionCard(
                            context,
                            title: tr.edit_ride,
                            icon: FontAwesomeIcons.penToSquare,
                            iconColor: context.appColors.primary,
                            onTap: () => EditRideListRoute().push(context),
                          ),
                          _buildQuickActionCard(
                            context,
                            title: tr.delete_ride,
                            icon: FontAwesomeIcons.trashCan,
                            iconColor: context.appColors.red,
                            onTap: () => DeleteRideRoute().push(context),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // قسم الإحصائيات السريعة
                  Column(
                    spacing: AppHeight.h10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        text: tr.quick_stats,
                        fontSize: AppFontSize.s16,
                      ),
                      Row(
                        spacing: AppWidth.w10,
                        children: [
                          _buildStatCard(context, tr.active_rides, '12'),
                          _buildStatCard(context, tr.completed_rides, '83'),
                          _buildStatCard(
                            context,
                            tr.rating,
                            '4.8',
                            icon: FontAwesomeIcons.solidStar,
                          ),
                        ],
                      ),
                    ],
                  ),

                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required FaIconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppPaddingHeight.p15),
          decoration: BoxDecoration(
            color: context.appColors.white,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            boxShadow: [
              BoxShadow(
                color: context.appColors.primary.withOpacity(0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            spacing: AppHeight.h8,
            children: [
              CircleAvatar(
                radius: AppRadius.r18,
                backgroundColor: iconColor.withOpacity(0.1),
                child: FaIcon(
                  icon,
                  color: iconColor,
                  size: AppSize.s16,
                ),
              ),
              BodyTitle(
                text: title,
                fontSize: AppFontSize.s13,
                fontWeight: AppFontWeight.bold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      {FaIconData? icon}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppPaddingHeight.p12),
        decoration: BoxDecoration(
          color: context.appColors.white,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(color: context.appColors.lightGreySec),
        ),
        child: Column(
          spacing: AppHeight.h4,
          children: [
            BodyTitle(
              text: title,
              fontSize: AppFontSize.s12,
              color: context.appColors.greyText,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppWidth.w4,
              children: [
                SectionTitle(
                  text: value,
                  fontSize: AppFontSize.s18,
                  fontWeight: AppFontWeight.bold,
                  color: context.appColors.primary,
                ),
                if (icon != null)
                  FaIcon(
                    icon,
                    size: AppSize.s14,
                    color: context.appColors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}