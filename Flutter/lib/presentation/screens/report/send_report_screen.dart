import 'package:a_tareqaak/core/l10n/app_localizations.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/domain/entity/report/report_entity.dart';
import 'package:a_tareqaak/presentation/bloc/report/create_report/create_report_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/report/create_report/i_create_report_event.dart';
import 'package:a_tareqaak/presentation/bloc/report/create_report/i_create_report_state.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class SendReportScreen extends StatelessWidget {
  final int userId; // معرّف المستخدم المُبلَّغ عنه
  final int? rideId; // معرّف الرحلة المرتبطة بالبلاغ (اختياري)

  const SendReportScreen({super.key, required this.userId, this.rideId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateReportBloc(),
      child: _SendReportContent(userId: userId, rideId: rideId),
    );
  }
}

class _SendReportContent extends StatefulWidget {
  final int userId;
  final int? rideId;

  const _SendReportContent({required this.userId, this.rideId});

  @override
  State<_SendReportContent> createState() => _SendReportContentState();
}

class _SendReportContentState extends State<_SendReportContent> {
  int selectedTypeIndex = 3; // افتراضياً تحرش
  final TextEditingController _detailsController = TextEditingController();

  List<Map<String, dynamic>> _reportTypes(BuildContext context) => [
    {
      'titleKey': 'dangerous',
      'subKey': 'dangerous_sub',
      'icon': FontAwesomeIcons.triangleExclamation,
      'color': context.appColors.red,
    },
    {
      'titleKey': 'fake',
      'subKey': 'fake_sub',
      'icon': FontAwesomeIcons.masksTheater,
      'color': context.appColors.primary,
    },
    {
      'titleKey': 'spam',
      'subKey': 'spam_sub',
      'icon': FontAwesomeIcons.envelope,
      'color': context.appColors.primary,
    },
    {
      'titleKey': 'harassment',
      'subKey': 'harassment_sub',
      'icon': FontAwesomeIcons.userGroup,
      'color': context.appColors.primary,
    },
    {
      'titleKey': 'inappropriate_content',
      'subKey': 'inappropriate_sub',
      'icon': FontAwesomeIcons.ban,
      'color': context.appColors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final reportTypes = _reportTypes(context);

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocConsumer<CreateReportBloc, ICreateReportState>(
          listener: (context, state) {
            if (state is CreateReportLoaded) {
              // عند نجاح إرسال البلاغ الانتقال المباشر لشاشة بلاغاتي
              MyReportsRoute().go(context);
            } else if (state is CreateReportFailed) {
              showCustomSnackBar(
                context: context,
                title: tr.error_title,
                message: state.message,
                contentType: ContentType.failure,
              );
            }
          },
          builder: (context, state) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppPaddingWidth.p20,
              vertical: AppPaddingHeight.p15,
            ),
            child: Column(
              spacing: AppHeight.h16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الشريط العلوي
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
                      text: tr.send_report_title,
                      fontSize: AppFontSize.s18,
                      fontWeight: AppFontWeight.bold,
                    ),
                    SizedBox(width: AppWidth.w40),
                  ],
                ),

                // 1. قسم نوع البلاغ
                Column(
                  spacing: AppHeight.h4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: AppWidth.w6,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: context.appColors.primary,
                          size: AppSize.s16,
                        ),
                        SectionTitle(
                          text: tr.report_type_section,
                          fontSize: AppFontSize.s14,
                        ),
                      ],
                    ),
                    BodyTitle(
                      text: tr.choose_report_type_sub,
                      fontSize: AppFontSize.s12,
                      color: context.appColors.greyText,
                    ),
                  ],
                ),

                // خيارات أنواع البلاغات الخمسة مع الراديو والأيقونات
                Container(
                  decoration: BoxDecoration(
                    color: context.appColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.r16),
                    border: Border.all(color: context.appColors.lightGreySec),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reportTypes.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: context.appColors.lightGreySec, height: 0),
                    itemBuilder: (context, index) {
                      final item = reportTypes[index];
                      return RadioListTile<int>(
                        value: index,
                        groupValue: selectedTypeIndex,
                        activeColor: context.appColors.primary,
                        onChanged: (val) {
                          setState(() {
                            selectedTypeIndex = val!;
                          });
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: AppHeight.h2,
                              children: [
                                SectionTitle(
                                  text: _getTranslatedTitle(
                                      tr, item['titleKey']),
                                  fontSize: AppFontSize.s14,
                                ),
                                BodyTitle(
                                  text: _getTranslatedTitle(tr, item['subKey']),
                                  fontSize: AppFontSize.s11,
                                  color: context.appColors.greyText,
                                ),
                              ],
                            ),
                            FaIcon(
                              item['icon'] ,
                              color: item['color'] as Color,
                              size: AppSize.s18,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 2. الرحلة المرتبطة بالمشكلة (اختياري)
                SectionTitle(
                  text: tr.related_ride_section,
                  fontSize: AppFontSize.s14,
                ),
                CustomInputField(
                  hintText: tr.select_ride_hint,
                  readOnly: true,
                  isExpanded: true,
                  suffixIcon: Center(
                    widthFactor: 1.0,
                    child: FaIcon(
                      FontAwesomeIcons.chevronDown,
                      color: context.appColors.greyText,
                      size: AppSize.s14,
                    ),
                  ),
                  prefixIcon: Center(
                    widthFactor: 1.0,
                    child: FaIcon(
                      FontAwesomeIcons.calendarDay,
                      color: context.appColors.primary,
                      size: AppSize.s16,
                    ),
                  ),
                ),

                // 3. نص البلاغ مع عداد الأحرف 0/500
                Column(
                  spacing: AppHeight.h4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      text: tr.report_text_section,
                      fontSize: AppFontSize.s14,
                    ),
                    BodyTitle(
                      text: tr.explain_details_sub,
                      fontSize: AppFontSize.s12,
                      color: context.appColors.greyText,
                    ),
                  ],
                ),
                CustomInputField(
                  controller: _detailsController,
                  hintText: tr.report_details_hint,
                  maxLines: 5,
                  maxLength: 500,
                  isExpanded: true,
                ),

                // زر إرسال البلاغ الرئيسي
                BlocBuilder<CreateReportBloc, ICreateReportState>(
                  builder: (context, state) {
                    return CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: state is CreateReportLoading,
                      onPressed: () => _submitReport(context, tr),
                      child: BodyTitle(
                        text: tr.send_report_btn,
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

  // بناء كيان البلاغ وإرساله عبر الـ API
  void _submitReport(BuildContext context, AppLocalizations tr) {
    final reason = _detailsController.text.trim();
    if (reason.isEmpty) {
      showCustomSnackBar(
        context: context,
        title: tr.warning_title,
        message: tr.explain_details_sub,
        contentType: ContentType.warning,
      );
      return;
    }

    final entity = CreateReportEntity(
      userId: widget.userId,
      type: _reportTypes(context)[selectedTypeIndex]['titleKey'] as String,
      reason: reason,
      ride: widget.rideId,
    );

    context.read<CreateReportBloc>().add(CreateReportEvent(entity));
  }

  String _getTranslatedTitle(AppLocalizations tr, String key) {
    switch (key) {
      case 'dangerous':
        return tr.dangerous;
      case 'dangerous_sub':
        return tr.dangerous_sub;
      case 'fake':
        return tr.fake;
      case 'fake_sub':
        return tr.fake_sub;
      case 'spam':
        return tr.spam;
      case 'spam_sub':
        return tr.spam_sub;
      case 'harassment':
        return tr.harassment;
      case 'harassment_sub':
        return tr.harassment_sub;
      case 'inappropriate_content':
        return tr.inappropriate_content;
      case 'inappropriate_sub':
        return tr.inappropriate_sub;
      default:
        return key;
    }
  }
}