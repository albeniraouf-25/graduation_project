import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/core/services/locator/locator.dart';
import 'package:a_tareqaak/data/data_source/auth/auth_storage_data_source.dart';
import 'package:a_tareqaak/domain/entity/rides/rides_no_params_entity.dart';
import 'package:a_tareqaak/presentation/bloc/payment/get_wallet_balance/get_wallet_balance_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/payment/get_wallet_balance/i_get_wallet_balance_event.dart';
import 'package:a_tareqaak/presentation/bloc/payment/get_wallet_balance/i_get_wallet_balance_state.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String? _userType; // 'rider' / 'driver'
  bool _roleLoaded = false;

  bool get _isRider => _userType == 'rider';

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final result = await locator<AuthStorageDataSource>().getUserType();
    if (!mounted) return;
    setState(() {
      _userType = result.fold((l) => null, (r) => r);
      _roleLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetWalletBalanceBloc()
        ..add(const GetWalletBalanceEvent(RidesNoParamsEntity())),
      child: _WalletContent(
        roleLoaded: _roleLoaded,
        isRider: _isRider,
      ),
    );
  }
}

class _WalletContent extends StatelessWidget {
  final bool roleLoaded;
  final bool isRider;

  const _WalletContent({required this.roleLoaded, required this.isRider});

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context
                .read<GetWalletBalanceBloc>()
                .add(const GetWalletBalanceEvent(RidesNoParamsEntity()));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      text: tr.wallet_and_payment,
                      fontSize: AppFontSize.s18,
                      fontWeight: AppFontWeight.bold,
                    ),
                    SizedBox(width: AppWidth.w40),
                  ],
                ),

                // بطاقة الرصيد — تعرض الرصيد الحقيقي من الـ API
                Container(
                  padding: EdgeInsets.all(AppPaddingWidth.p20),
                  decoration: BoxDecoration(
                    color: context.appColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                  ),
                  child: Column(
                    spacing: AppHeight.h8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTitle(
                        text: tr.wallet_balance,
                        color: context.appColors.white.withOpacity(0.8),
                      ),
                      BlocBuilder<GetWalletBalanceBloc,
                          IGetWalletBalanceState>(
                        builder: (context, state) {
                          if (state is GetWalletBalanceLoading ||
                              state is GetWalletBalanceInitial) {
                            return Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: AppHeight.h8),
                              child: SizedBox(
                                height: AppSize.s24,
                                width: AppSize.s24,
                                child: CircularProgressIndicator(
                                  color: context.appColors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          final balance = state is GetWalletBalanceLoaded
                              ? (state.responseModel?.data?.balance ?? '0')
                              : '0';
                          return SectionTitle(
                            text: '$balance ${tr.syrian_pound}',
                            color: context.appColors.white,
                            fontSize: AppFontSize.s24,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                if (!roleLoaded)
                  Padding(
                    padding: EdgeInsets.only(top: AppHeight.h20),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: context.appColors.primary),
                    ),
                  )
                else ...[
                  // خيارات الشحن + طلبات الإيداع تظهر للراكب فقط
                  if (isRider) ...[
                    SectionTitle(
                      text: tr.charge_balance,
                      fontSize: AppFontSize.s14,
                      color: context.appColors.primary,
                    ),
                    _buildTile(
                      context,
                      icon: FontAwesomeIcons.mobileRetro,
                      iconColor: context.appColors.red,
                      title: tr.syriatel_cash,
                      onTap: () =>
                          ChargeWalletRoute(method: 'syriatel_cash')
                              .push(context),
                    ),
                    _buildTile(
                      context,
                      icon: FontAwesomeIcons.wallet,
                      iconColor: context.appColors.darkGreen,
                      title: tr.sham_cash,
                      onTap: () =>
                          ChargeWalletRoute(method: 'sham_cash').push(context),
                    ),
                    _buildTile(
                      context,
                      icon: FontAwesomeIcons.receipt,
                      iconColor: context.appColors.orange,
                      title: tr.deposit_requests_title,
                      onTap: () => DepositRequestsRoute().push(context),
                    ),
                  ] else
                    // السائق يرى سجل المعاملات فقط
                    BodyTitle(
                      text: tr.wallet_history_only,
                      fontSize: AppFontSize.s13,
                      color: context.appColors.greyText,
                    ),

                  // سجل المعاملات — متاح للطرفين
                  _buildTile(
                    context,
                    icon: FontAwesomeIcons.list,
                    iconColor: context.appColors.blackText,
                    title: tr.transaction_history,
                    onTap: () => TransactionHistoryRoute().push(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required FaIconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r14),
        border: Border.all(color: context.appColors.lightGreySec),
      ),
      child: ListTile(
        onTap: onTap,
        leading: FaIcon(icon, color: iconColor, size: AppSize.s20),
        title: BodyTitle(text: title, fontWeight: AppFontWeight.bold),
        trailing: FaIcon(
          FontAwesomeIcons.chevronLeft,
          size: AppSize.s14,
          color: context.appColors.greyText,
        ),
      ),
    );
  }
}
