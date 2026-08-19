import 'package:a_tareqaak/core/extension/validation_extension.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/presentation/bloc/auth/login/i_login_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/login/i_login_state.dart';
import 'package:a_tareqaak/presentation/cubit/auth/login/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/bloc/auth/login/login_bloc.dart';
import 'package:a_tareqaak/presentation/cubit/auth/login/login_cubit.dart';
import 'package:a_tareqaak/presentation/cubit/language/language_cubit.dart';
import 'package:a_tareqaak/presentation/screens/auth/widgets/auth_header_widget.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تجميع LoginCubit (للـ UI) مع LoginBloc (للـ API)
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginCubit()),
        BlocProvider(create: (_) => LoginBloc()),
      ],
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent({super.key});
  

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _passwordcontroller = TextEditingController();
  var _emailcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final tr = context.loc;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocConsumer<LoginBloc, ILoginState>(
          listener: (context, apiState) {
            if (apiState is LoginLoaded) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: tr.login_to_access,
                contentType: ContentType.success,
              );
              // التوجيه حسب نوع المستخدم عند نجاح تسجيل الدخول
              final userType =
                  apiState.tokensModel?.data?.user?.userType;
              if (userType == 'driver') {
               
                  DriverHomeRoute().go(context);
                }
              else {
                RiderHomeRoute().go(context);
              }
            } else if (apiState is LoginFailed) {
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
                    // زر تبديل اللغة أعلى الشاشة
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: InkWell(
                        onTap: () {
                          final langCubit = context.read<LanguageCubit>();
                          final newLocale =
                              Localizations.localeOf(context).languageCode == 'ar'
                                  ? const Locale('en')
                                  : const Locale('ar');
                          langCubit.setLocale(newLocale);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: AppWidth.w5,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.globe,
                              color: context.appColors.blackText,
                              size: AppSize.s18,
                            ),
                            BodyTitle(
                              text: tr.language_switch,
                              fontWeight: AppFontWeight.medium,
                              fontSize: AppFontSize.s14,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // الهيدر الرئيسي (اللوجو والعنوان)
                    AuthHeaderWidget(
                      title: tr.welcome_back,
                      subtitle: tr.login_to_access,
                    ),

                    // حقل البريد الإلكتروني (يحدث LoginCubit)
                    CustomInputField(
                      controller: _emailcontroller,
                      hintText: tr.email_hint,
                      title: tr.email,
                      isExpanded: true,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (val) {
                        context.read<LoginCubit>().emailChanged(val);
                      },
                      prefixIcon: Center(
                        widthFactor: 1.0,
                        child: FaIcon(
                          FontAwesomeIcons.envelope,
                          color: context.appColors.grey,
                          size: AppSize.s20,
                        ),
                      ),
                    ),

                    // حقل كلمة المرور (يقرأ حالة الرؤية والبيانات من LoginCubit)
                    BlocBuilder<LoginCubit, LoginCubitState>(
                      builder: (context, cubitState) {
                        final cubit = context.read<LoginCubit>();
                        return CustomInputField(
                          controller: _passwordcontroller,
                          hintText: tr.password_hint,
                          title: tr.password,
                          isSecure: cubitState.isPasswordObscured,
                          isExpanded: true,
                          maxLines: 1,
                          validator: (value) => AppValidators.validatePassword(
                            value,
                            tr.field_required,
                            tr.passwords_dont_match,
                          ),
                          onChanged: (val) {
                            cubit.passwordChanged(val);
                          },
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
                              size: AppSize.s18,
                            ),
                            onPressed: () {
                              cubit.togglePasswordVisibility();
                            },
                            
                          ),
                        );
                      },
                    ),

                    // 👈 رابط نسيت كلمة المرور؟ (ينقل لشاشة ForgotPassword)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: InkWell(
                        onTap: () {
                          ForgotPasswordRoute().push(context);
                        },
                        child: BodyTitle(
                          text: tr.forgot_password,
                          color: context.appColors.primary,
                          fontSize: AppFontSize.s13,
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                    ),

                    // زر تسجيل الدخول الرئيسي
                    CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: apiState is LoginLoading,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final entity =
                              context.read<LoginCubit>().state.entity;
                          if (entity != null) {
                            context.read<LoginBloc>().add(LoginEvent(entity));
                          }
                        }
                      },
                      child: BodyTitle(
                        text: tr.login,
                        color: context.appColors.white,
                        fontSize: AppFontSize.s16,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),

                    // 👈 رابط "ليس لديك حساب؟ إنشاء حساب جديد" (ينقل لشاشة Register)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: AppWidth.w4,
                      children: [
                        BodyTitle(
                          text: tr.dont_have_account,
                          color: context.appColors.greyText,
                          fontSize: AppFontSize.s14,
                        ),
                        InkWell(
                          onTap: () {
                            RegisterRoute().go(context);
                          },
                          child: BodyTitle(
                            text: tr.create_new_account,
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