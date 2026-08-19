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
import 'package:a_tareqaak/domain/entity/payment/payment_entity.dart';
import 'package:a_tareqaak/presentation/bloc/payment/create_deposit_request/create_deposit_request_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/payment/create_deposit_request/i_create_deposit_request_event.dart';
import 'package:a_tareqaak/presentation/bloc/payment/create_deposit_request/i_create_deposit_request_state.dart';
import 'package:a_tareqaak/presentation/widgets/custom_bottom_sheet.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class ChargeWalletScreen extends StatelessWidget {
  final String? method; // syriatel_cash / sham_cash

  const ChargeWalletScreen({super.key, this.method});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateDepositRequestBloc(),
      child: _ChargeWalletContent(method: method ?? 'syriatel_cash'),
    );
  }
}

class _ChargeWalletContent extends StatefulWidget {
  final String method;

  const _ChargeWalletContent({required this.method});

  @override
  State<_ChargeWalletContent> createState() => _ChargeWalletContentState();
}

class _ChargeWalletContentState extends State<_ChargeWalletContent> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '50000');

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String get _methodLabel =>
      widget.method == 'sham_cash' ? context.loc.sham_cash : context.loc.syriatel_cash;

  void _showSuccessSheet(BuildContext context) {
    final tr = context.loc;
    CustomBottomSheet.show(
      context,
      title: tr.charge_request_submitted,
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
            text: tr.charge_request_sub,
            textAlign: TextAlign.center,
            fontSize: AppFontSize.s13,
          ),
          CustomElevatedButton(
            height: AppHeight.h45,
            width: double.infinity,
            borderRadius: AppRadius.r12,
            color: context.appColors.primary,
            onPressed: () {
              context.pop(); // إغلاق الـ bottom sheet
              context.pop(); // العودة لشاشة المحفظة
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

  void _submit(BuildContext context) {
    final tr = context.loc;
    final phone = _phoneController.text.trim();
    final amount = _amountController.text.trim().replaceAll(',', '');

    if (!phone.isValidPhone) {
      showCustomSnackBar(
        context: context,
        title: tr.error_title,
        message: tr.enter_valid_phone,
        contentType: ContentType.failure,
      );
      return;
    }
    if (amount.isEmpty || (double.tryParse(amount) ?? 0) <= 0) {
      showCustomSnackBar(
        context: context,
        title: tr.error_title,
        message: tr.amount,
        contentType: ContentType.failure,
      );
      return;
    }

    context.read<CreateDepositRequestBloc>().add(
          CreateDepositRequestEvent(
            CreateDepositRequestEntity(
              amount: amount,
              paymentMethod: widget.method,
              transactionReference: phone,
            ),
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
        child: BlocListener<CreateDepositRequestBloc,
            ICreateDepositRequestState>(
          listener: (context, state) {
            if (state is CreateDepositRequestLoaded) {
              _showSuccessSheet(context);
            } else if (state is CreateDepositRequestFailed) {
              showCustomSnackBar(
                context: context,
                title: tr.error_title,
                message: state.message.isNotEmpty
                    ? state.message
                    : tr.charge_request_failed,
                contentType: ContentType.failure,
              );
            }
          },
          child: Padding(
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
                      text: '${tr.charge_balance} - $_methodLabel',
                      fontSize: AppFontSize.s18,
                      fontWeight: AppFontWeight.bold,
                    ),
                    SizedBox(width: AppWidth.w40),
                  ],
                ),

                CustomInputField(
                  controller: _phoneController,
                  title: tr.sender_number,
                  hintText: '09XXXXXXXX',
                  textInputType: TextInputType.phone,
                  isExpanded: true,
                ),

                CustomInputField(
                  controller: _amountController,
                  title: tr.amount,
                  hintText: '50000',
                  textInputType: TextInputType.number,
                  isExpanded: true,
                ),

                // خيارات المبالغ السريعة
                Row(
                  spacing: AppWidth.w8,
                  children: [
                    _buildAmountChip('25000'),
                    _buildAmountChip('50000'),
                    _buildAmountChip('100000'),
                  ],
                ),

                const Spacer(),

                BlocBuilder<CreateDepositRequestBloc,
                    ICreateDepositRequestState>(
                  builder: (context, state) {
                    return CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: state is CreateDepositRequestLoading,
                      onPressed: () => _submit(context),
                      child: BodyTitle(
                        text: tr.charge_balance,
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

  Widget _buildAmountChip(String label) {
    return Expanded(
      child: InkWell(
        onTap: () => _amountController.text = label,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppPaddingHeight.p8),
          decoration: BoxDecoration(
            color: context.appColors.white,
            borderRadius: BorderRadius.circular(AppRadius.r8),
            border: Border.all(color: context.appColors.lightGreySec),
          ),
          child: BodyTitle(
            text: label,
            textAlign: TextAlign.center,
            fontSize: AppFontSize.s12,
          ),
        ),
      ),
    );
  }
}
