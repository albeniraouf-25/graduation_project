import 'package:a_tareqaak/presentation/bloc/auth/resend_reset_code/i_resend_reset_code_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/resend_reset_code/i_resend_reset_code_state.dart';
import 'package:a_tareqaak/presentation/bloc/auth/resend_reset_code/resend_reset_code_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/auth/resend_verification/i_resend_verification_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/verify_email/i_verify_email_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/verify_email/i_verify_email_state.dart';
import 'package:a_tareqaak/presentation/bloc/auth/verify_reset_code/i_verify_reset_code_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/verify_reset_code/i_verify_reset_code_state.dart';
import 'package:a_tareqaak/presentation/cubit/auth/verify_email/verify_email_state.dart';
import 'package:a_tareqaak/presentation/cubit/profile/driver_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/domain/entity/auth/resend_reset_code/resend_reset_code.dart';
import 'package:a_tareqaak/domain/entity/auth/resend_verification/resend_verification_entity.dart';
import 'package:a_tareqaak/domain/entity/auth/verify_email/verify_email_entity.dart';
import 'package:a_tareqaak/domain/entity/auth/verify_reset_code/verify_reset_code_entity.dart';
import 'package:a_tareqaak/presentation/bloc/auth/resend_verification/resend_verification_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/auth/verify_email/verify_email_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/auth/verify_reset_code/verify_reset_code_bloc.dart';
import 'package:a_tareqaak/presentation/cubit/auth/verify_email/verify_email_cubit.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class CheckCodeScreen extends StatelessWidget {
  final String email;
  final bool isForgotPassword;
  final String? resetToken;

  const CheckCodeScreen({
    super.key,
    this.email = '',
    this.isForgotPassword = false,
    this.resetToken,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => VerifyEmailCubit(email)),
        BlocProvider(create: (_) => VerifyEmailBloc()),
        BlocProvider(create: (_) => VerifyResetCodeBloc()),
        BlocProvider(create: (_) => ResendVerificationBloc()),
        BlocProvider(create: (_) => ResendResetCodeBloc()),
      ],
      child: _CheckCodeContent(
        email: email,
        isForgotPassword: isForgotPassword,
        resetToken: resetToken,
      ),
    );
  }
}

class _CheckCodeContent extends StatefulWidget {
  final String email;
  final bool isForgotPassword;
  final String? resetToken;

  const _CheckCodeContent({
    required this.email,
    required this.isForgotPassword,
    this.resetToken,
  });

  
  @override
  State<_CheckCodeContent> createState() => _CheckCodeContentState();
}

class _CheckCodeContentState extends State<_CheckCodeContent> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  @override
  void initState() {
    super.initState();

    debugPrint('EMAIL = ${widget.email}');
    debugPrint('IS FORGOT PASSWORD = ${widget.isForgotPassword}');
    debugPrint('RESET TOKEN = ${widget.resetToken}');
  }
  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onVerifyPressed(BuildContext context) {
    final cubitEntity = context.read<VerifyEmailCubit>().state.entity;
    final code = cubitEntity?.code ?? '';

    if (code.length < 6) {
      showCustomSnackBar(
        context: context,
        title: context.loc.warning_title,
        message: context.loc.invalid_otp,
        contentType: ContentType.warning,
      );
      return;
    }

    if (widget.isForgotPassword) {
      // 👈 الاستدعاء بالاسم المعتمد VerifyResetCodeEvent
      context.read<VerifyResetCodeBloc>().add(
            VerifyResetCodeEvent(
              VerifyResetCodeEntity(
                resetToken: widget.resetToken ?? '',
                code: code,
              ),
            ),
          );
    } else {
      // 👈 الاستدعاء بالاسم المعتمد VerifyEmailEvent
      context.read<VerifyEmailBloc>().add(
            VerifyEmailEvent(
              VerifyEmailEntity(
                email: widget.email,
                code: code,
              ),
            ),
          );
    }
  }

  String _formatTime(int seconds) {
    final minutesStr = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            // 1. الاستماع لنتيجة تأكيد البريدVerifyEmailLoaded و userModel
            BlocListener<VerifyEmailBloc, IVerifyEmailState>(
              listener: (context, apiState) {
                if (apiState is VerifyEmailLoaded) {
                  showCustomSnackBar(
                    context: context,
                    title: tr.success_title,
                    message: tr.ride_updated_success,
                    contentType: ContentType.success,
                  );

                  final userType = apiState.userModel?.data?.userType;
                  if (userType == 'driver') {
                    final profileCubit = context.read<DriverProfileCubit>();
                    if (!profileCubit.isProfileComplete) {
                      EditDriverProfileRoute(isMandatory: true).go(context);
                    } else {
                      DriverHomeRoute().go(context);
                    }
                  } else {
                    RiderHomeRoute().go(context);
                  }
                } else if (apiState is VerifyEmailFailed) {
                  showCustomSnackBar(
                    context: context,
                    title: tr.error_title,
                    message: apiState.message,
                    contentType: ContentType.failure,
                  );
                }
              },
            ),

            // 2. الاستماع لنتيجة تأكيد كود نسيت كلمة المرور VerifyResetCodeLoaded
            BlocListener<VerifyResetCodeBloc, IVerifyResetCodeState>(
              listener: (context, apiState) {
                if (apiState is VerifyResetCodeLoaded) {
                  showCustomSnackBar(
                    context: context,
                    title: tr.success_title,
                    message: tr.success_title,
                    contentType: ContentType.success,
                  );
                  debugPrint("reset_token before reset password route ${widget.resetToken}");
                  ResetPasswordRoute(resetToken: widget.resetToken!).pushReplacement(context);
                  
                } else if (apiState is VerifyResetCodeFailed) {
                  showCustomSnackBar(
                    context: context,
                    title: tr.error_title,
                    message: apiState.message,
                    contentType: ContentType.failure,
                  );
                }
              },
            ),

            // 3. الاستماع لنتيجة إعادة إرسال كود استعادة كلمة المرور
            BlocListener<ResendResetCodeBloc, IResendResetCodeState>(
              listener: (context, apiState) {
                if (apiState is ResendResetCodeLoaded) {
                  showCustomSnackBar(
                    context: context,
                    title: tr.success_title,
                    message: tr.resend_code,
                    contentType: ContentType.success,
                  );
                } else if (apiState is ResendResetCodeFailed) {
                  showCustomSnackBar(
                    context: context,
                    title: tr.error_title,
                    message: apiState.message,
                    contentType: ContentType.failure,
                  );
                }
              },
            ),
          ],
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppPaddingWidth.p25,
              vertical: AppPaddingHeight.p15,
            ),
            child: Column(
              spacing: AppHeight.h20,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // زر العودة
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

                // أيقونة البريد
                Center(
                  child: Container(
                    width: AppWidth.w130,
                    height: AppHeight.h130,
                    decoration: BoxDecoration(
                      color: context.appColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppRadius.r20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.envelope,
                          size: AppSize.s100,
                          color: context.appColors.primary,
                        ),
                        Positioned(
                          bottom: AppHeight.h12,
                          right: AppWidth.w12,
                          child: CircleAvatar(
                            radius: AppRadius.r12,
                            backgroundColor: context.appColors.green,
                            child: FaIcon(
                              FontAwesomeIcons.check,
                              color: context.appColors.white,
                              size: AppSize.s12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // العناوين
                Column(
                  spacing: AppHeight.h6,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SectionTitle(
                      text: tr.verify_email_title,
                      fontSize: AppFontSize.s22,
                      fontWeight: AppFontWeight.bold,
                      color: context.appColors.primary,
                      textAlign: TextAlign.center,
                    ),
                    BodyTitle(
                      text: '${tr.verify_email_sub} ',
                      fontSize: AppFontSize.s14,
                      color: context.appColors.greyText,
                      textAlign: TextAlign.center,
                    ),
                    BodyTitle(
                      text: widget.email,
                      fontSize: AppFontSize.s14,
                      fontWeight: AppFontWeight.bold,
                      color: context.appColors.primary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // حقول الـ OTP المكونة من 5 أرقام
                BlocBuilder<VerifyEmailCubit, VerifyEmailCubitState>(
                  builder: (context, cubitState) {
                    final cubit = context.read<VerifyEmailCubit>();
                    return Directionality(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: AppWidth.w8,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: AppWidth.w55,
                            height: AppHeight.h60,
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppFontSize.s20,
                                fontWeight: AppFontWeight.bold,
                                color: context.appColors.blackText,
                              ),
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: context.appColors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r12),
                                  borderSide: BorderSide(
                                    color: context.appColors.lightGreySec,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r12),
                                  borderSide: BorderSide(
                                    color: context.appColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
  cubit.codeChanged(index, value);

  if (value.isNotEmpty && index < 5) {
    _focusNodes[index + 1].requestFocus();
  } else if (value.isEmpty && index > 0) {
    _focusNodes[index - 1].requestFocus();
  }
},
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),

                // المؤقت الزمني وزر إعادة الإرسال
                BlocBuilder<VerifyEmailCubit, VerifyEmailCubitState>(
                  builder: (context, cubitState) {
                    return Column(
                      spacing: AppHeight.h8,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!cubitState.canResend)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: AppWidth.w4,
                            children: [
                              BodyTitle(
                                text: tr.resend_code_in,
                                color: context.appColors.greyText,
                                fontSize: AppFontSize.s14,
                              ),
                              BodyTitle(
                                text: _formatTime(cubitState.timerSeconds),
                                color: context.appColors.primary,
                                fontWeight: AppFontWeight.bold,
                                fontSize: AppFontSize.s14,
                              ),
                            ],
                          ),
                        InkWell(
                          onTap: cubitState.canResend
                              ? () {
                                  if (widget.isForgotPassword) {
                                    // إعادة إرسال كود استعادة كلمة المرور
                                    context.read<ResendResetCodeBloc>().add(
                                          ResendResetCodeEvent(
                                            ResendResetCodeEntity(
                                              resetToken:
                                                  widget.resetToken ?? '',
                                            ),
                                          ),
                                        );
                                  } else {
                                    // 👈 الاستدعاء بالاسم المعتمد ResendVerificationEvent
                                    context.read<ResendVerificationBloc>().add(
                                          ResendVerificationEvent(
                                            ResendVerificationEntity(
                                                email: widget.email),
                                          ),
                                        );
                                  }
                                }
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: AppWidth.w6,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.arrowsRotate,
                                size: AppSize.s18,
                                color: cubitState.canResend
                                    ? context.appColors.primary
                                    : context.appColors.grey,
                              ),
                              BodyTitle(
                                text: tr.resend_code,
                                color: cubitState.canResend
                                    ? context.appColors.primary
                                    : context.appColors.grey,
                                fontWeight: AppFontWeight.bold,
                                fontSize: AppFontSize.s14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // زر التأكيد
                BlocBuilder<VerifyEmailBloc, IVerifyEmailState>(
                  builder: (context, emailApiState) {
                    return BlocBuilder<VerifyResetCodeBloc,
                        IVerifyResetCodeState>(
                      builder: (context, resetApiState) {
                        final isLoading = emailApiState is VerifyEmailLoading ||
                            resetApiState is VerifyResetCodeLoading;

                        return CustomElevatedButton(
                          height: AppHeight.h50,
                          width: double.infinity,
                          borderRadius: AppRadius.r12,
                          color: context.appColors.primary,
                          loading: isLoading,
                          onPressed: () => _onVerifyPressed(context),
                          child: BodyTitle(
                            text: tr.verify_code_btn,
                            color: context.appColors.white,
                            fontSize: AppFontSize.s16,
                            fontWeight: AppFontWeight.bold,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}