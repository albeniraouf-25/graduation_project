import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/presentation/cubit/profile/driver_profile_cubit.dart';
import 'package:a_tareqaak/presentation/cubit/profile/driver_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/extension/validation_extension.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class EditUserProfileScreen extends StatefulWidget {
  final bool isMandatory; // إجبار السائق الجديد على ملء البيانات

  const EditUserProfileScreen({super.key, this.isMandatory = false});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _carController;
  late final TextEditingController _colorController;
  late final TextEditingController _plateController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DriverProfileCubit>();
    _nameController = TextEditingController(text: cubit.driverName);
    _phoneController = TextEditingController(text: cubit.phone);
    _carController = TextEditingController(text: cubit.carName);
    _colorController = TextEditingController(text: cubit.carColor);
    _plateController = TextEditingController(text: cubit.carPlate);
    _locationController = TextEditingController(text: cubit.currentLocation);
    // ضبط نوع المستخدم لإظهار الحقول المناسبة (سائق/راكب)
    cubit.ensureUserTypeLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _carController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: !widget.isMandatory,
      child: Scaffold(
        backgroundColor: context.appColors.backGround,
        body: SafeArea(
          child: BlocListener<DriverProfileCubit, DriverProfileState>(
            listener: (context, state) {
              if (state is DriverProfileSuccessState) {
                if (widget.isMandatory) {
                    DriverHomeRoute().go(context);
                } else {
                  context.pop();
                }
              }
            },
            child: SingleChildScrollView(
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
                      if (!widget.isMandatory)
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: FaIcon(
                            isRtl
                                ? FontAwesomeIcons.chevronRight
                                : FontAwesomeIcons.chevronLeft,
                            color: context.appColors.blackText,
                            size: AppSize.s20,
                          ),
                        )
                      else
                        SizedBox(width: AppWidth.w40),
                      SectionTitle(
                        text: tr.edit_profile_title,
                        fontSize: AppFontSize.s18,
                        fontWeight: AppFontWeight.bold,
                      ),
                      SizedBox(width: AppWidth.w40),
                    ],
                  ),

                  if (widget.isMandatory)
                    Container(
                      padding: EdgeInsets.all(AppPaddingWidth.p12),
                      decoration: BoxDecoration(
                        color: context.appColors.lightOrange,
                        borderRadius: BorderRadius.circular(AppRadius.r12),
                      ),
                      child: BodyTitle(
                        text: tr.complete_profile_mandatory,
                        color: context.appColors.orange,
                        fontSize: AppFontSize.s12,
                        textAlign: TextAlign.center,
                      ),
                    ),

                  CustomInputField(
                    controller: _nameController,
                    title: tr.full_name,
                    hintText: tr.full_name,
                    isExpanded: true,
                  ),
                  CustomInputField(
                    controller: _phoneController,
                    title: tr.phone_number,
                    hintText: tr.phone_number,
                    textInputType: TextInputType.phone,
                    isExpanded: true,
                  ),
                  // حقول السيارة تظهر للسائق فقط
                  if (!context.read<DriverProfileCubit>().isRider) ...[
                    CustomInputField(
                      controller: _carController,
                      title: tr.car_name,
                      hintText: tr.car_name,
                      isExpanded: true,
                    ),
                    CustomInputField(
                      controller: _colorController,
                      title: tr.car_color,
                      hintText: tr.car_color,
                      isExpanded: true,
                    ),
                    CustomInputField(
                      controller: _plateController,
                      title: tr.car_plate,
                      hintText: tr.car_plate,
                      isExpanded: true,
                    ),
                  ],
                  // حقل الموقع الحالي يظهر للراكب فقط
                  if (context.read<DriverProfileCubit>().isRider)
                    CustomInputField(
                      controller: _locationController,
                      title: tr.current_location,
                      hintText: tr.current_location,
                      isExpanded: true,
                    ),

                  BlocConsumer<DriverProfileCubit, DriverProfileState>(
                    listener: (context, state) {
                      // Handle state changes if needed
                    },
                    builder: (context, state) {
                      return CustomElevatedButton(
                        height: AppHeight.h50,
                        width: double.infinity,
                        borderRadius: AppRadius.r12,
                        color: context.appColors.primary,
                        loading: state is DriverProfileLoadingState,
                        onPressed: () {
                          // التحقق من رقم الهاتف السوري قبل الحفظ
                          final phone = _phoneController.text.trim();
                          if (!phone.isValidPhone) {
                            showCustomSnackBar(
                              context: context,
                              title: tr.error_title,
                              message: tr.enter_valid_phone,
                              contentType: ContentType.failure,
                            );
                            return;
                          }
                          // يوجّه الكيوبيت تلقائيًا لـ update_rider أو update_driver
                          context.read<DriverProfileCubit>().updateProfile(
                                name: _nameController.text.trim(),
                                phoneNum: _phoneController.text.trim(),
                                car: _carController.text.trim(),
                                color: _colorController.text.trim(),
                                plate: _plateController.text.trim(),
                                location: _locationController.text.trim(),
                              );
                        },
                        child: BodyTitle(
                          text: tr.save_changes,
                          color: context.appColors.white,
                          fontSize: AppFontSize.s16,
                          fontWeight: AppFontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}