// lib/presentation/screens/settings/customer_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/cubit/customer_service/customer_service_cubit.dart';
import 'package:a_tareqaak/presentation/cubit/customer_service/customer_service_state.dart';
import 'package:a_tareqaak/presentation/widgets/custom_bottom_sheet.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerServiceCubit(),
      child: const _CustomerServiceContent(),
    );
  }
}

class _CustomerServiceContent extends StatefulWidget {
  const _CustomerServiceContent();

  @override
  State<_CustomerServiceContent> createState() =>
      _CustomerServiceContentState();
}

class _CustomerServiceContentState extends State<_CustomerServiceContent> {
  final TextEditingController _textController = TextEditingController();

  void _showSuccessSheet(BuildContext context) {
    final tr = context.loc;
    CustomBottomSheet.show(
      context,
      title: tr.report_received_title,
      body: Column(
        spacing: AppHeight.h16,
        children: [
          CircleAvatar(
            radius: AppRadius.r30,
            backgroundColor: context.appColors.green,
            child: FaIcon(
              FontAwesomeIcons.check,
              color: context.appColors.white,
              size: AppSize.s24,
            ),
          ),
          BodyTitle(
            text: tr.report_received_desc,
            textAlign: TextAlign.center,
            fontSize: AppFontSize.s14,
          ),
          CustomElevatedButton(
            height: AppHeight.h45,
            width: double.infinity,
            borderRadius: AppRadius.r12,
            color: context.appColors.primary,
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: BodyTitle(
              text: tr.ok,
              color: context.appColors.white,
              fontWeight: AppFontWeight.bold,
            ),
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
        child: BlocListener<CustomerServiceCubit, CustomerServiceState>(
          listener: (context, state) {
            if (state is CustomerServiceSuccessState) {
              _showSuccessSheet(context);
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
                    SectionTitle(
                      text: tr.customer_service,
                      fontSize: AppFontSize.s18,
                      fontWeight: AppFontWeight.bold,
                    ),
                    SizedBox(width: AppWidth.w40),
                  ],
                ),

                BodyTitle(
                  text: tr.customer_service_subtitle,
                  fontSize: AppFontSize.s13,
                  color: context.appColors.greyText,
                ),

                // حقل وصف المشكلة مع عداد الأحرف 0/500
                CustomInputField(
                  controller: _textController,
                  hintText: tr.describe_issue_hint,
                  maxLines: 6,
                  maxLength: 500,
                  isExpanded: true,
                ),

                BlocBuilder<CustomerServiceCubit, CustomerServiceState>(
                  builder: (context, state) {
                    return CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: state is CustomerServiceLoadingState,
                      onPressed: () {
                        context
                            .read<CustomerServiceCubit>()
                            .submitReport(_textController.text);
                      },
                      child: BodyTitle(
                        text: tr.send,
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
    );
  }
}