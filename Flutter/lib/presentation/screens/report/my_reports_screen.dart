import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/data/models/report/report_data_model.dart';
import 'package:a_tareqaak/domain/entity/rides/rides_no_params_entity.dart';
import 'package:a_tareqaak/presentation/bloc/report/get_my_reports/get_my_reports_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/report/get_my_reports/i_get_my_reports_event.dart';
import 'package:a_tareqaak/presentation/bloc/report/get_my_reports/i_get_my_reports_state.dart';
import 'package:a_tareqaak/presentation/screens/report/report_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetMyReportsBloc()
        ..add(const GetMyReportsEvent(RidesNoParamsEntity())),
      child: const _MyReportsContent(),
    );
  }
}

class _MyReportsContent extends StatelessWidget {
  const _MyReportsContent();

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
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
                    onPressed: () { context.pop();},
                    icon: FaIcon(
                      isRtl
                          ? FontAwesomeIcons.chevronRight
                          : FontAwesomeIcons.chevronLeft,
                      color: context.appColors.blackText,
                      size: AppSize.s20,
                    ),
                  ),
                  SectionTitle(
                    text: tr.my_reports_title,
                    fontSize: AppFontSize.s18,
                    fontWeight: AppFontWeight.bold,
                  ),
                  SizedBox(width: AppWidth.w40),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<GetMyReportsBloc, IGetMyReportsState>(
                builder: (context, state) {
                  if (state is GetMyReportsLoading ||
                      state is GetMyReportsInitial) {
                    return Center(
                      child:
                          CircularProgressIndicator(color: context.appColors.primary),
                    );
                  }
                  if (state is GetMyReportsFailed) {
                    return _MessageView(
                      message: state.message,
                      onRetry: () => context.read<GetMyReportsBloc>().add(
                          const GetMyReportsEvent(RidesNoParamsEntity())),
                    );
                  }
                  final reports = state is GetMyReportsLoaded
                      ? (state.responseModel?.data?.reports ??
                          <ReportDataModel>[])
                      : <ReportDataModel>[];

                  if (reports.isEmpty) {
                    return _MessageView(message: tr.no_data);
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context.read<GetMyReportsBloc>().add(
                        const GetMyReportsEvent(RidesNoParamsEntity())),
                    child: ListView.separated(
                      padding: EdgeInsets.all(AppPaddingWidth.p20),
                      itemCount: reports.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppHeight.h12),
                      itemBuilder: (context, index) =>
                          _buildReportCard(context, reports[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportDataModel report) {
    final tr = context.loc;
    final bool isPending = report.status != 'reviewed';

    return Container(
      padding: EdgeInsets.all(AppPaddingWidth.p16),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => ReportDetailsRoute($extra: report).push(context),
        child: Column(
          spacing: AppHeight.h8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPaddingWidth.p10,
                    vertical: AppPaddingHeight.p4,
                  ),
                  decoration: BoxDecoration(
                    color: isPending
                        ? context.appColors.lightOrange
                        : context.appColors.lightPrim,
                    borderRadius: BorderRadius.circular(AppRadius.r6),
                  ),
                  child: BodyTitle(
                    text: localizeReportStatus(tr, report.status),
                    fontSize: AppFontSize.s12,
                    color: isPending ? context.appColors.orange : context.appColors.darkGreen,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
                SectionTitle(
                  text: localizeReportType(tr, report.type),
                  fontSize: AppFontSize.s16,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: BodyTitle(
                    text: report.reason ?? '',
                    fontSize: AppFontSize.s13,
                    color: context.appColors.greyText,
                    maxLines: 2,
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  size: AppSize.s14,
                  color: context.appColors.greyText,
                ),
              ],
            ),
            BodyTitle(
              text: formatReportDate(report.createdAt),
              fontSize: AppFontSize.s12,
              color: context.appColors.greyText,
            ),
          ],
        ),
      ),
    );
  }
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
