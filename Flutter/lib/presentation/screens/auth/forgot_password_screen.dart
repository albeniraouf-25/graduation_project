import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/presentation/bloc/auth/forgot_password/i_forgot_password_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/forgot_password/i_forgot_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/extension/validation_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';

import 'package:a_tareqaak/presentation/bloc/auth/forgot_password/forgot_password_bloc.dart';
import 'package:a_tareqaak/presentation/cubit/auth/forgot_password/forgot_password_cubit.dart';
import 'package:a_tareqaak/presentation/screens/auth/widgets/auth_header_widget.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ForgotPasswordCubit()),
        BlocProvider(create: (_) => ForgotPasswordBloc()),
      ],
      child: const _ForgotPasswordContent(),
    );
  }
}

class _ForgotPasswordContent extends StatefulWidget {
  const _ForgotPasswordContent({super.key});

  @override
  State<_ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<_ForgotPasswordContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordBloc, IForgotPasswordState>(
          listener: (context, apiState) {
            // 👈 الحالة المعتمدة ForgotPasswordLoaded
            if (apiState is ForgotPasswordLoaded) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: apiState.responseModel?.data?.message ?? '',
                contentType: ContentType.success,
              );
               debugPrint(
      'RESET TOKEN FROM API = ${apiState.responseModel?.data?.resetToken}',
    );
              // الانتقال لشاشة إدخال الرمز وتمرير الـ resetToken والـ email
              CheckCodeRoute(
  email: apiState.responseModel?.data?.email ?? '',
  isForgotPassword: true,
  resetToken: apiState.responseModel?.data?.resetToken ?? '',
).push(context);
           
            } else if (apiState is ForgotPasswordFailed) {
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
                  spacing: AppHeight.h20,
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
                      title: tr.forgot_password,
                      subtitle: tr.reset_password_subtitle,
                    ),

                    // حقل البريد الإلكتروني
                    CustomInputField(
                      hintText: tr.email_hint,
                      title: tr.email,
                      isExpanded: true,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (val) {
                        context.read<ForgotPasswordCubit>().emailChanged(val);
                      },
                      prefixIcon: Center(
                        widthFactor: 1.0,
                        child: FaIcon(
                          FontAwesomeIcons.envelope,
                          color: context.appColors.grey,
                          size: AppSize.s20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return tr.field_required;
                        }
                        if (!value.isValidEmail) {
                          return tr.enter_valid_email;
                        }
                        return null;
                      },
                    ),

                    // زر إرسال الرمز الرئيسي
                    CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: apiState is ForgotPasswordLoading,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final entity =
                              context.read<ForgotPasswordCubit>().state.entity;
                          if (entity != null) {
                            // 👈 إرسال الحدث ForgotPasswordEvent
                            context
                                .read<ForgotPasswordBloc>()
                                .add(ForgotPasswordEvent(entity));
                          }
                        }
                      },
                      child: BodyTitle(
                        text: tr.send,
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