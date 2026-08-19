import 'package:a_tareqaak/core/resources/app_assets.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/presentation/cubit/profile/driver_profile_cubit.dart';
import 'package:a_tareqaak/presentation/cubit/profile/driver_profile_state.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/helper/launch_url_helper.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/image_view.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class UserProfileScreen extends StatefulWidget {
  final bool isOtherUser; // خاصية فحص هل البروفايل لمستخدم آخر لتحديد خيار الإبلاغ
  final int? otherUserId; // معرّف المستخدم الآخر لاستخدامه في الإبلاغ

  const UserProfileScreen({
    super.key,
    this.isOtherUser = false,
    this.otherUserId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل بيانات البروفايل الحقيقية من الخادم للمستخدم الحالي فقط
    if (!widget.isOtherUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<DriverProfileCubit>().loadProfile();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileContent(
      isOtherUser: widget.isOtherUser,
      otherUserId: widget.otherUserId,
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final bool isOtherUser;
  final int? otherUserId;

  const _ProfileContent({required this.isOtherUser, this.otherUserId});

  void _showReportDialog(BuildContext context) {
    final tr = context.loc;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: SectionTitle(text: tr.report_account),
        content: BodyTitle(text: tr.report_account_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: BodyTitle(text: tr.cancel, color: context.appColors.greyText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              SendReportRoute(userId: otherUserId ?? 0).push(context);
            },
            child: BodyTitle(text: tr.ok, color: context.appColors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocConsumer<DriverProfileCubit, DriverProfileState>(
          builder: (context, state) {
            final cubit = context.read<DriverProfileCubit>();

            return SingleChildScrollView(
              child: Column(
                spacing: AppHeight.h16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الهيدر الرئيسي مع غلاف السيارة والصورة الشخصية المتداخلة
                  // نحيط الـ Stack بـ SizedBox يحجز مساحة تدلّي الصورة الشخصية
                  // حتى تبقى أيقونة الكاميرا داخل حدود الـ Stack وتكون قابلة للنقر.
                  SizedBox(
                    height: AppHeight.h220 + AppHeight.h50,
                    child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => cubit.pickCarCoverImage(context),
                          child: ImageView(
                            imagePath: cubit.carCoverImagePath ?? AppAssets.defult,
                            height: AppHeight.h220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppHeight.h15,
                        left: isRtl ? null : AppWidth.w15,
                        right: isRtl ? AppWidth.w15 : null,
                        child: CircleAvatar(
                          backgroundColor: context.appColors.white,
                          radius: AppRadius.r18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => context.pop(),
                            icon: FaIcon(
                              isRtl
                                  ? FontAwesomeIcons.chevronRight
                                  : FontAwesomeIcons.chevronLeft,
                              color: context.appColors.blackText,
                              size: AppSize.s16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppHeight.h15,
                        left: isRtl ? AppWidth.w15 : null,
                        right: isRtl ? null : AppWidth.w15,
                        child: CircleAvatar(
                          backgroundColor: context.appColors.white,
                          radius: AppRadius.r18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: isOtherUser
                                ? () => _showReportDialog(context)
                                : () {},
                            icon: FaIcon(
                              isOtherUser
                                  ? FontAwesomeIcons.triangleExclamation
                                  : FontAwesomeIcons.ellipsisVertical,
                              color: isOtherUser
                                  ? context.appColors.red
                                  : context.appColors.blackText,
                              size: AppSize.s16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppPaddingWidth.p4),
                              decoration: BoxDecoration(
                                color: context.appColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: ImageView(
                                imagePath: cubit.profileImagePath ?? AppAssets.profilePlaceholder,
                                name: cubit.profileImagePath == null
                                    ? cubit.driverName
                                    : null,
                                height: AppHeight.h120,
                                width: AppWidth.w120,
                                radius: BorderRadius.circular(AppRadius.r100),
                                fit: BoxFit.cover,
                              ),
                            ),
                            InkWell(
                              onTap: () => cubit.pickProfileImage(context),
                              child: CircleAvatar(
                                radius: AppRadius.r18,
                                backgroundColor: context.appColors.primary,
                                child: FaIcon(
                                  FontAwesomeIcons.camera,
                                  size: AppSize.s14,
                                  color: context.appColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    ),
                  ),

                  // البيانات الأساسية
                  Column(
                    spacing: AppHeight.h4,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppWidth.w6,
                        children: [
                          SectionTitle(
                            text: cubit.driverName,
                            fontSize: AppFontSize.s22,
                            fontWeight: AppFontWeight.bold,
                          ),
                          FaIcon(
                            FontAwesomeIcons.circleCheck,
                            color: context.appColors.primaryLight,
                            size: AppSize.s18,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppWidth.w4,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.solidStar,
                            color: context.appColors.orange,
                            size: AppSize.s14,
                          ),
                          BodyTitle(
                            text: '4.8 (128)',
                            fontSize: AppFontSize.s14,
                            fontWeight: AppFontWeight.bold,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppWidth.w6,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.calendarDay,
                            color: context.appColors.greyText,
                            size: AppSize.s12,
                          ),
                          BodyTitle(
                            text: tr.joined_date,
                            color: context.appColors.greyText,
                            fontSize: AppFontSize.s12,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // أزرار الإجراءات السريعة (اتصال وإبلاغ)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppPaddingWidth.p20),
                    child: Row(
                      spacing: AppWidth.w12,
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            height: AppHeight.h45,
                            borderRadius: AppRadius.r12,
                            color: context.appColors.backGround,
                            borderSide:
                                BorderSide(color: context.appColors.greyDivider),
                            onPressed: () {
                              LaunchUrlHelper.call(cubit.phone);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: AppWidth.w8,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.phone,
                                  color: context.appColors.primary,
                                  size: AppSize.s16,
                                ),
                                BodyTitle(
                                  text: tr.call,
                                  color: context.appColors.primary,
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // زر الإبلاغ يظهر للمستخدمين الآخرين فقط
                        if (isOtherUser)
                          Expanded(
                            child: CustomElevatedButton(
                              height: AppHeight.h45,
                              borderRadius: AppRadius.r12,
                              color: context.appColors.white,
                              borderSide: BorderSide(color: context.appColors.red),
                              onPressed: () {
                                SendReportRoute(userId: otherUserId ?? 0)
                                    .push(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: AppWidth.w8,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.flag,
                                    color: context.appColors.red,
                                    size: AppSize.s16,
                                  ),
                                  BodyTitle(
                                    text: tr.report,
                                    color: context.appColors.red,
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // معلومات الاتصال
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppPaddingWidth.p20),
                    child: Column(
                      spacing: AppHeight.h8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          text: tr.contact_info_header,
                          fontSize: AppFontSize.s14,
                          color: context.appColors.primary,
                        ),
                        Container(
                          padding: EdgeInsets.all(AppPaddingWidth.p14),
                          decoration: BoxDecoration(
                            color: context.appColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.r14),
                            border: Border.all(color: context.appColors.lightGreySec),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: AppWidth.w10,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.phone,
                                    size: AppSize.s16,
                                    color: context.appColors.primary,
                                  ),
                                  BodyTitle(text: cubit.phone),
                                ],
                              ),
                              FaIcon(
                                FontAwesomeIcons.chevronLeft,
                                size: AppSize.s12,
                                color: context.appColors.greyText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // معلومات السيارة تظهر للسائق فقط
                  if (!cubit.isRider)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPaddingWidth.p20),
                      child: Column(
                        spacing: AppHeight.h8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            text: tr.car_info_header,
                            fontSize: AppFontSize.s14,
                            color: context.appColors.primary,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: context.appColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.r16),
                              border: Border.all(color: context.appColors.lightGreySec),
                            ),
                            child: Column(
                              children: [
                                _buildCarDetailRow(
                                  context,
                                  icon: FontAwesomeIcons.car,
                                  label: tr.car_type,
                                  value: cubit.carName,
                                ),
                                Divider(
                                    color: context.appColors.lightGreySec, height: 0),
                                _buildCarDetailRow(
                                  context,
                                  icon: FontAwesomeIcons.palette,
                                  label: tr.car_color,
                                  value: cubit.carColor,
                                ),
                                Divider(
                                    color: context.appColors.lightGreySec, height: 0),
                                _buildCarDetailRow(
                                  context,
                                  icon: FontAwesomeIcons.calendarDay,
                                  label: tr.plate_number,
                                  value: cubit.carPlate,
                                ),
                                
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // موقع الراكب الحالي يظهر للراكب فقط
                  if (cubit.isRider && cubit.currentLocation.isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPaddingWidth.p20),
                      child: Column(
                        spacing: AppHeight.h8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            text: tr.current_location,
                            fontSize: AppFontSize.s14,
                            color: context.appColors.primary,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: context.appColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.r16),
                              border: Border.all(color: context.appColors.lightGreySec),
                            ),
                            child: _buildCarDetailRow(
                              context,
                              icon: FontAwesomeIcons.locationDot,
                              label: tr.current_location,
                              value: cubit.currentLocation,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // زر تعديل البروفايل في الأسفل
                  if (!isOtherUser)
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppPaddingWidth.p20,
                        right: AppPaddingWidth.p20,
                        bottom: AppPaddingHeight.p20,
                      ),
                      child: CustomElevatedButton(
                        height: AppHeight.h50,
                        width: double.infinity,
                        borderRadius: AppRadius.r12,
                        color: context.appColors.primary,
                        onPressed: () => EditDriverProfileRoute().push(context),
                        child: BodyTitle(
                          text: tr.edit_profile_btn,
                          color: context.appColors.white,
                          fontSize: AppFontSize.s16,
                          fontWeight: AppFontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }, listener: (BuildContext context, DriverProfileState state) {
            if (state is DriverProfileImageUploadedState) {
              showCustomSnackBar(
                context: context,
                title: context.loc.success_title,
                message: context.loc.success_title,
                contentType: ContentType.success,
              );
            } else if (state is DriverProfileImageUploadFailedState) {
              showCustomSnackBar(
                context: context,
                title: context.loc.error_title,
                message: state.message,
                contentType: ContentType.failure,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCarDetailRow(
    BuildContext context, {
    required FaIconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.all(AppPaddingWidth.p14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: AppWidth.w10,
            children: [
              FaIcon(icon, size: AppSize.s16, color: context.appColors.primary),
              BodyTitle(text: label, fontSize: AppFontSize.s14),
            ],
          ),
          Row(
            spacing: AppWidth.w8,
            children: [
              BodyTitle(
                text: value,
                fontSize: AppFontSize.s14,
                fontWeight: AppFontWeight.bold,
              ),
              FaIcon(
                FontAwesomeIcons.chevronLeft,
                size: AppSize.s12,
                color: context.appColors.greyText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}