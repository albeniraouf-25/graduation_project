import 'package:a_tareqaak/data/models/ride/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';

import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

// بطاقة الرحلة بصفحات الراكب (تم إزالة صورة واسم السائق كما طُلِب)
class RiderRideCardWidget extends StatelessWidget {
  final RideModel ride;
  final String? statusTag; // محجوزة / معلقة / ملغية / مرفوضة
  final Color? statusColor;
  final VoidCallback? onBookTap;
  final VoidCallback? onCancelTap;
  final VoidCallback? onTapCard;

  const RiderRideCardWidget({
    super.key,
    required this.ride,
    this.statusTag,
    this.statusColor,
    this.onBookTap,
    this.onCancelTap,
    this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;

    return Container(
      padding: EdgeInsets.all(AppPaddingWidth.p16),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTapCard,
        child: Column(
          spacing: AppHeight.h10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مسار الرحلة وشارة الحالة إن وجدت
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: AppWidth.w8,
                  children: [
                    SectionTitle(
                      text: ride.departureCity,
                      fontSize: AppFontSize.s16,
                    ),
                    FaIcon(
                      FontAwesomeIcons.arrowRightLong,
                      size: AppSize.s14,
                      color: context.appColors.primary,
                    ),
                    SectionTitle(
                      text: ride.destinationCity,
                      fontSize: AppFontSize.s16,
                    ),
                  ],
                ),
                if (statusTag != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPaddingWidth.p8,
                      vertical: AppPaddingHeight.p4,
                    ),
                    decoration: BoxDecoration(
                      color: (statusColor ?? context.appColors.primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.r6),
                    ),
                    child: BodyTitle(
                      text: statusTag!,
                      fontSize: AppFontSize.s12,
                      color: statusColor ?? context.appColors.primary,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
              ],
            ),

            // اليوم والساعة
            BodyTitle(
              text: 'اليوم - ${ride.departureDateTime.hour}:${ride.departureDateTime.minute.toString().padLeft(2, '0')} صباحاً',
              fontSize: AppFontSize.s13,
              color: context.appColors.greyText,
            ),

            // السعر والمقاعد المتاحة مع أزرار الإجراء (حجز / إلغاء)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppHeight.h2,
                  children: [
                    BodyTitle(
                      text: '${ride.availableSeats} ${tr.available_seats_count}',
                      fontSize: AppFontSize.s12,
                      color: context.appColors.primary,
                      fontWeight: AppFontWeight.bold,
                    ),
                    SectionTitle(
                      text: '${ride.price.toInt()} ${tr.syrian_pound}',
                      fontSize: AppFontSize.s15,
                      color: context.appColors.blackText,
                    ),
                  ],
                ),
                if (onBookTap != null)
                  CustomElevatedButton(
                    height: AppHeight.h35,
                    borderRadius: AppRadius.r10,
                    color: context.appColors.primary,
                    onPressed: onBookTap!,
                    child: BodyTitle(
                      text: tr.book_btn,
                      color: context.appColors.white,
                      fontSize: AppFontSize.s13,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                if (onCancelTap != null)
                  CustomElevatedButton(
                    height: AppHeight.h35,
                    borderRadius: AppRadius.r10,
                    color: context.appColors.lightRed,
                    borderSide: BorderSide(color: context.appColors.red),
                    onPressed: onCancelTap!,
                    child: BodyTitle(
                      text: tr.cancel_booking_btn,
                      color: context.appColors.red,
                      fontSize: AppFontSize.s13,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}