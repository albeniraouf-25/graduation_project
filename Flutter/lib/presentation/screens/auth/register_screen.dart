import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/presentation/bloc/auth/register/i_register_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/register/i_register_state.dart';
import 'package:a_tareqaak/presentation/cubit/auth/register/register_state.dart';
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
import 'package:a_tareqaak/presentation/bloc/auth/register/register_bloc.dart';
import 'package:a_tareqaak/presentation/cubit/auth/register/register_cubit.dart';
import 'package:a_tareqaak/presentation/screens/auth/widgets/auth_header_widget.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_drop_down_field.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RegisterCubit()),
        BlocProvider(create: (_) => RegisterBloc()),
      ],
      child: const _RegisterContent(),
    );
  }
}

class _RegisterContent extends StatefulWidget {
  const _RegisterContent();

  @override
  State<_RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<_RegisterContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    if (!cubit.state.isTermsAccepted) {
      showCustomSnackBar(
        context: context,
        title: context.loc.warning_title,
        message: context.loc.must_agree_terms,
        contentType: ContentType.warning,
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final entity = cubit.state.entity;
      if (entity != null) {
        // 👈 الاستدعاء بالاسم المطابق RegisterEvent
        context.read<RegisterBloc>().add(RegisterEvent(entity));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocConsumer<RegisterBloc, IRegisterState>(
          listener: (context, apiState) {
            // 👈 الحالة المطابقة لقوافل RegisterLoaded ورؤية userModel
            if (apiState is RegisterLoaded) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: tr.ride_published_success,
                contentType: ContentType.success,
              );
              final email =
                  context.read<RegisterCubit>().state.entity?.email ?? '';
              CheckCodeRoute(
  email: email,
  
).push(context);
            } else if (apiState is RegisterFailed) {
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
                    // زر العودة للخلف
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
                      title: tr.create_account_title,
                      subtitle: tr.start_journey,
                    ),

                    // حقل الاسم الكامل
                    CustomInputField(
                      controller: _fullNameController,
                      hintText: tr.full_name_hint,
                      title: tr.full_name,
                      isExpanded: true,
                      textInputType: TextInputType.name,
                      onChanged: (val) =>
                          context.read<RegisterCubit>().nameChanged(val),
                      prefixIcon: Center(
                        widthFactor: 1.0,
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          color: context.appColors.grey,
                          size: AppSize.s20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return tr.field_required;
                        }
                        return null;
                      },
                    ),

                    // حقل اختيار الدور (سائق / راكب)
                    CustomDropDownField(
                      title: tr.role,
                      showInputField: false,
                      dropDownHint: tr.select_role_hint,
                      dropDownItems: [tr.driver, tr.rider],
                      requiredInput: true,
                      onDropDownChanged: (selectedVal) {
                        final type =
                            selectedVal == tr.driver ? 'driver' : 'rider';
                        context.read<RegisterCubit>().userTypeChanged(type);
                      },
                    ),

                    // حقل البريد الإلكتروني
                    CustomInputField(
                      controller: _emailController,
                      hintText: tr.email_hint,
                      isExpanded: true,
                      title: tr.email,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (val) =>
                          context.read<RegisterCubit>().emailChanged(val),
                      prefixIcon: Center(
                        widthFactor: 1.0,
                        child: FaIcon(
                          FontAwesomeIcons.envelope,
                          color: context.appColors.grey,
                          size: AppSize.s20,
                        ),
                      ),
                      validator: (value) => AppValidators.validateEmail(
                        value,
                        tr.field_required,
                        tr.enter_valid_email,
                      ),
                    ),

                    // حقل كلمة المرور
                    BlocBuilder<RegisterCubit, RegisterCubitState>(
                      builder: (context, cubitState) {
                        final cubit = context.read<RegisterCubit>();
                        return CustomInputField(
                          controller: _passwordController,
                          hintText: tr.password_hint,
                          title: tr.password,
                          isExpanded: true,
                          maxLines: 1,
                          isSecure: cubitState.isPasswordObscured,
                          onChanged: (val) => cubit.passwordChanged(val),
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
                          validator: (value) => AppValidators.validatePassword(
                          
                            value,
                            tr.field_required,
                            tr.password_too_short,
                          ),
                        );
                      },
                    ),

                    // حقل تأكيد كلمة المرور
                    BlocBuilder<RegisterCubit, RegisterCubitState>(
                      builder: (context, cubitState) {
                        final cubit = context.read<RegisterCubit>();
                        return CustomInputField(
                          controller: _confirmPasswordController,
                          hintText: tr.confirm_password_hint,
                          title: tr.confirm_password,
                          isExpanded: true,
                          isSecure: cubitState.isConfirmPasswordObscured,
                          maxLines: 1,
                          onChanged: (val) =>
                              cubit.confirmPasswordChanged(val),
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
                          validator: (value) => AppValidators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                            tr.field_required,
                            tr.passwords_dont_match,
                          ),
                        );
                      },
                    ),

                    // مربع التحديد للشروط والأحكام
                    BlocBuilder<RegisterCubit, RegisterCubitState>(
                      builder: (context, cubitState) {
                        final cubit = context.read<RegisterCubit>();
                        return Row(
                          spacing: AppWidth.w5,
                          children: [
                            Checkbox(
                              value: cubitState.isTermsAccepted,
                              activeColor: context.appColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r4),
                              ),
                              onChanged: (val) {
                                cubit.toggleTerms(val);
                              },
                            ),
                            Expanded(
                              child: BodyTitle(
                                text: tr.agree_terms,
                                fontSize: AppFontSize.s12,
                                color: context.appColors.blackText,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // زر إنشاء الحساب
                    CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: apiState is RegisterLoading,
                      onPressed: () => _onRegisterPressed(context),
                      child: BodyTitle(
                        text: tr.create_account_btn,
                        color: context.appColors.white,
                        fontSize: AppFontSize.s16,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),

                    // رابط تسجيل الدخول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: AppWidth.w4,
                      children: [
                        BodyTitle(
                          text: tr.already_have_account,
                          color: context.appColors.greyText,
                          fontSize: AppFontSize.s14,
                        ),
                        InkWell(
                          onTap: () {
                            context.pop();
                          },
                          child: BodyTitle(
                            text: tr.login,
                            color: context.appColors.primary,
                            fontSize: AppFontSize.s14,
                            fontWeight: AppFontWeight.bold,
                          ),
                        ),
                      ],
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