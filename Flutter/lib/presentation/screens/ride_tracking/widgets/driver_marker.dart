import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';

class DriverMarkerWidget extends StatelessWidget {
  const DriverMarkerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: context.appColors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.carSide,
          color: context.appColors.white,
          size: AppSize.s16,
        ),
      ),
    );
  }
}