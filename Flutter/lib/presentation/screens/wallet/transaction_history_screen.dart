import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/data/models/payment/payment_models.dart';
import 'package:a_tareqaak/domain/entity/rides/rides_no_params_entity.dart';
import 'package:a_tareqaak/presentation/bloc/payment/get_transaction/get_transactions_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/payment/get_transaction/i_get_transactions_event.dart';
import 'package:a_tareqaak/presentation/bloc/payment/get_transaction/i_get_transactions_state.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocProvider(
      create: (_) => GetTransactionsBloc()
        ..add(const GetTransactionsEvent(RidesNoParamsEntity())),
      child: Scaffold(
        backgroundColor: context.appColors.backGround,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPaddingWidth.p20,
                  vertical: AppPaddingHeight.p15,
                ),
                child: Row(
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
                      text: tr.transaction_history,
                      fontSize: AppFontSize.s18,
                      fontWeight: AppFontWeight.bold,
                    ),
                    SizedBox(width: AppWidth.w40),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<GetTransactionsBloc, IGetTransactionsState>(
                  builder: (context, state) {
                    if (state is GetTransactionsLoading ||
                        state is GetTransactionsInitial) {
                      return Center(
                        child:
                            CircularProgressIndicator(color: context.appColors.primary),
                      );
                    }
                    if (state is GetTransactionsFailed) {
                      return _MessageView(
                        message: state.message,
                        onRetry: () => context.read<GetTransactionsBloc>().add(
                            const GetTransactionsEvent(RidesNoParamsEntity())),
                      );
                    }
                    final transactions = state is GetTransactionsLoaded
                        ? (state.responseModel?.data?.transactions ??
                            <TransactionDataModel>[])
                        : <TransactionDataModel>[];

                    if (transactions.isEmpty) {
                      return _MessageView(message: tr.no_transactions);
                    }

                    return RefreshIndicator(
                      onRefresh: () async => context
                          .read<GetTransactionsBloc>()
                          .add(const GetTransactionsEvent(
                              RidesNoParamsEntity())),
                      child: ListView.separated(
                        padding: EdgeInsets.all(AppPaddingWidth.p20),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppHeight.h12),
                        itemBuilder: (context, index) =>
                            _buildTransactionCard(context, transactions[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, TransactionDataModel trx) {
    final tr = context.loc;
    FaIconData icon;
    Color color;
    String label;
    switch (trx.transactionType) {
      case 'deposit':
        icon = FontAwesomeIcons.arrowDown;
        color = context.appColors.darkGreen;
        label = tr.trx_deposit;
        break;
      case 'earning':
        icon = FontAwesomeIcons.sackDollar;
        color = context.appColors.darkGreen;
        label = tr.trx_earning;
        break;
      case 'refund':
        icon = FontAwesomeIcons.rotateLeft;
        color = context.appColors.orange;
        label = tr.trx_refund;
        break;
      case 'payment':
      default:
        icon = FontAwesomeIcons.arrowUp;
        color = context.appColors.red;
        label = tr.trx_payment;
    }

    return Container(
      padding: EdgeInsets.all(AppPaddingWidth.p16),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: context.appColors.lightGreySec),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppRadius.r20,
            backgroundColor: color.withOpacity(0.12),
            child: FaIcon(icon, color: color, size: AppSize.s16),
          ),
          SizedBox(width: AppWidth.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppHeight.h4,
              children: [
                SectionTitle(text: label, fontSize: AppFontSize.s15),
                BodyTitle(
                  text: _formatDate(trx.createdAt),
                  fontSize: AppFontSize.s12,
                  color: context.appColors.greyText,
                ),
              ],
            ),
          ),
          BodyTitle(
            text: '#${trx.id ?? '-'}',
            fontSize: AppFontSize.s12,
            color: context.appColors.greyText,
          ),
        ],
      ),
    );
  }
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  // ISO like 2024-05-10T10:30:00Z -> 2024-05-10 10:30
  final normalized = raw.replaceFirst('T', ' ');
  return normalized.length >= 16 ? normalized.substring(0, 16) : normalized;
}

class _MessageView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _MessageView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppHeight.h12,
        children: [
          BodyTitle(
            text: message,
            textAlign: TextAlign.center,
            color: context.appColors.greyText,
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: BodyTitle(text: tr.retry, color: context.appColors.primary),
            ),
        ],
      ),
    );
  }
}
