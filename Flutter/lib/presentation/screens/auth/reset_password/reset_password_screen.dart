import 'package:a_tareqaak/core/extension/validation_extension.dart';
import 'package:a_tareqaak/presentation/bloc/auth/reset_password/i_reset_password_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/reset_password/i_reset_password_state.dart';
import 'package:a_tareqaak/presentation/cubit/auth/reset_password/reset_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/bloc/auth/reset_password/reset_password_bloc.dart';
import 'package:a_tareqaak/presentation/cubit/auth/reset_password/reset_password_cubit.dart';
import 'package:a_tareqaak/presentation/screens/auth/widgets/auth_header_widget.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ResetPasswordCubit(resetToken)),
        BlocProvider(create: (_) => ResetPasswordBloc()),
      ],
      child: const _ResetPasswordContent(),
    );
  }
}

class _ResetPasswordContent extends StatefulWidget {
  const _ResetPasswordContent();

  @override
  State<_ResetPasswordContent> createState() => _ResetPasswordContentState();
}

class _ResetPasswordContentState extends State<_ResetPasswordContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _passwordcontroller  = TextEditingController();
  var _confirmcontroller  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocConsumer<ResetPasswordBloc, IResetPasswordState>(
          listener: (context, apiState) {
            if (apiState is ResetPasswordLoaded) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: tr.password_reset_success,
                contentType: ContentType.success,
              );
              // الانتقال المباشر لشاشة تسجيل الدخول
              context.go('/login');
            } else if (apiState is ResetPasswordFailed) {
              showCustomSnackBar(
                context: context,
                title: tr.error_title,
                message: apiState.message,
                contentType: ContentType.failure,
              );
            }
          },
          builder: (context, apiState) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppPaddingWidth.p25,
                vertical: AppPaddingHeight.p15,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: AppHeight.h16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // زر الرجوع
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: FaIcon(
                          isRtl
                              ? FontAwesomeIcons.chevronRight
                              : FontAwesomeIcons.chevronLeft,
                          color: context.appColors.blackText,
                          size: AppSize.s20,
                        ),
                      ),
                    ),

                    // الهيدر الرئيسي
                    AuthHeaderWidget(
                      title: tr.reset_password_title,
                      subtitle: tr.reset_password_subtitle,
                    ),

                    // حقل كلمة المرور الجديدة
                    BlocBuilder<ResetPasswordCubit, ResetPasswordCubitState>(
                      builder: (context, cubitState) {
                        final cubit = context.read<ResetPasswordCubit>();
                        return CustomInputField(
                          hintText: tr.new_password,
                          title: tr.new_password,
                          isExpanded: true,
                          maxLines: 1,
                          isSecure: cubitState.isPasswordObscured,
                          prefixIcon: Center(
                            widthFactor: 1.0,
                            child: FaIcon(
                              FontAwesomeIcons.lock,
                              color: context.appColors.grey,
                              size: AppSize.s20,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: FaIcon(
                              cubitState.isPasswordObscured
                                  ? FontAwesomeIcons.eyeSlash
                                  : FontAwesomeIcons.eye,
                              color: context.appColors.grey,
                              size: AppSize.s20,
                            ),
                            onPressed: () {
                              cubit.togglePasswordVisibility();
                            },
                          ),
                          onChanged: (val) {
                            cubit.newPasswordChanged(val);
                          },
                          validator: (value) => AppValidators.validatePassword(
                            value,
                            tr.field_required,
                            tr.passwords_dont_match,
                          ),
                        );
                      },
                    ),

                    // حقل تأكيد كلمة المرور الجديدة
                    BlocBuilder<ResetPasswordCubit, ResetPasswordCubitState>(
                      builder: (context, cubitState) {
                        final cubit = context.read<ResetPasswordCubit>();
                        return CustomInputField(
                          controller: _confirmcontroller,
                          hintText: tr.confirm_new_password,
                          title: tr.confirm_new_password,
                          isExpanded: true,
                          maxLines: 1,
                          isSecure: cubitState.isConfirmPasswordObscured,
                          prefixIcon: Center(
                            widthFactor: 1.0,
                            child: FaIcon(
                              FontAwesomeIcons.lock,
                              color: context.appColors.grey,
                              size: AppSize.s20,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: FaIcon(
                              cubitState.isConfirmPasswordObscured
                                  ? FontAwesomeIcons.eyeSlash
                                  : FontAwesomeIcons.eye,
                              color: context.appColors.grey,
                              size: AppSize.s20,
                            ),
                            onPressed: () {
                              cubit.toggleConfirmPasswordVisibility();
                            },
                          ),
                          onChanged: (val) {
                            cubit.confirmPasswordChanged(val);
                          },
                          validator: (value) => AppValidators.validateConfirmPassword(
                            value,
                            _confirmcontroller.text,
                            tr.field_required,
                            tr.passwords_dont_match,
                          ),
                        );
                      },
                    ),

                    // زر حفظ كلمة المرور الجديدة
                    CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: apiState is ResetPasswordLoading,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final entity =
                              context.read<ResetPasswordCubit>().state.entity;
                          if (entity != null) {
                            // إرسال الحدث إلى ResetPasswordBloc
                            context
                                .read<ResetPasswordBloc>()
                                .add(ResetPasswordEvent(entity));
                          }
                        }
                      },
                      child: BodyTitle(
                        text: tr.save_new_password,
                        color: context.appColors.white,
                        fontSize: AppFontSize.s16,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}