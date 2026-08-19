import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class RideTrackingInfoCard extends StatelessWidget {
  final RideDataModel ride;
  final bool isConnected;
  final String? lastUpdated;

  const RideTrackingInfoCard({
    super.key,
    required this.ride,
    required this.isConnected,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPaddingWidth.p16),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppHeight.h10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: AppWidth.w8,
                children: [
                  CircleAvatar(
                    radius: AppRadius.r6,
                    backgroundColor:
                        isConnected ? context.appColors.green : context.appColors.red,
                  ),
                  BodyTitle(
                    text: isConnected ? "تتبع مباشر نشط" : "جاري الاتصال...",
                    fontSize: AppFontSize.s13,
                    color: isConnected ? context.appColors.green : context.appColors.greyText,
                    fontWeight: AppFontWeight.bold,
                  ),
                ],
              ),
              SectionTitle(
                text: "${ride.cost ?? ''} ل.س",
                fontSize: AppFontSize.s15,
                color: context.appColors.primary,
              ),
            ],
          ),
          Divider(color: context.appColors.lightGreySec),
          Row(
            children: [
              CircleAvatar(
                radius: AppRadius.r20,
                backgroundColor: context.appColors.lightGrey,
                child: FaIcon(
                  FontAwesomeIcons.user,
                  color: context.appColors.primary,
                  size: AppSize.s18,
                ),
              ),
              SizedBox(width: AppWidth.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppHeight.h4,
                  children: [
                    SectionTitle(
                      text: ride.driverInfo?.driverName ?? "السائق",
                      fontSize: AppFontSize.s14,
                    ),
                    BodyTitle(
                      text: "${ride.location ?? ''} ➔ ${ride.destination ?? ''}",
                      fontSize: AppFontSize.s12,
                      color: context.appColors.greyText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}