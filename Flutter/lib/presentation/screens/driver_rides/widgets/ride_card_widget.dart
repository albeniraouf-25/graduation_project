import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

// بطاقة إظهار تفاصيل الرحلة مع تأثير Glow خفيف باللون الأساسي #006874
class RideCardWidget extends StatelessWidget {
  final String fromCity;
  final String toCity;
  final String dateAndPriceText;
  final String seatsText;
  final VoidCallback? onTap;

  const RideCardWidget({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.dateAndPriceText,
    required this.seatsText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPaddingWidth.p16),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        // إضافة ظل ناعم وفخم جداً باستخدام لون الهوية الأساسي #006874
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          spacing: AppHeight.h10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مسار الرحلة (اللاذقية -> دمشق)
            Row(
              spacing: AppWidth.w8,
              children: [
                SectionTitle(
                  text: fromCity,
                  fontSize: AppFontSize.s16,
                  color: context.appColors.blackText,
                ),
                FaIcon(
                  FontAwesomeIcons.arrowRightLong,
                  size: AppSize.s14,
                  color: context.appColors.primary,
                ),
                SectionTitle(
                  text: toCity,
                  fontSize: AppFontSize.s16,
                  color: context.appColors.blackText,
                ),
              ],
            ),

            // التاريخ والسعر
            BodyTitle(
              text: dateAndPriceText,
              fontSize: AppFontSize.s13,
              color: context.appColors.greyText,
            ),

            // المقاعد المتاحة
            BodyTitle(
              text: seatsText,
              fontSize: AppFontSize.s13,
              color: context.appColors.primary,
              fontWeight: AppFontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}