import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_assets.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/image_view.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class AuthHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppHeight.h8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ImageView(
          imagePath: AppAssets.logo,
          fit: BoxFit.contain,
          //height: AppHeight.h400,
        ),
        SectionTitle(
          text: title,
          fontSize: AppFontSize.s22,
          fontWeight: AppFontWeight.bold,
          color: context.appColors.primary,
          textAlign: TextAlign.center,
        ),
        BodyTitle(
          text: subtitle,
          fontSize: AppFontSize.s14,
          color: context.appColors.greyText,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}