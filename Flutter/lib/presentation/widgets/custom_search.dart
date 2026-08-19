import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import '../../core/resources/app_values.dart';

import 'custom_text_from_field.dart';

class CustomSearch extends StatelessWidget {
  final Color color;
  final Color? prefixIconColor;
  final Color? hintColor;
  final double? paddingEnd;
  final double? paddingStart;
  final double? paddingBottom;
  final double? paddingTop;
  final double? borderRadius;
  final bool? readOnly;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final TextEditingController? controller;

  const CustomSearch({
    super.key,
    required this.color,
    this.paddingEnd,
    this.paddingStart,
    this.paddingBottom,
    this.paddingTop,
    this.borderRadius,
    this.readOnly = false,
    this.prefixIconColor,
    this.hintColor,
    this.controller,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        end: paddingEnd ?? 0,
        start: paddingStart ?? 0,
        bottom: paddingBottom ?? 0,
        top: paddingTop ?? 0,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppHeight.h50,
        child: CustomTextFromField(
          maxLines: 1,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          controller: controller,
          contentPaddingTop: AppPaddingHeight.p17,
          readOnly: readOnly,
          prefixIcon: FaIcon(
            FontAwesomeIcons.search,
            color: context.appColors.primary,
            size: AppSize.s20,
          ),
          hintColor: hintColor ?? context.appColors.greyText,
          onTap: onTap,
          borderRadius: borderRadius ?? AppRadius.r45,
          hintText: context.loc.search_city_hint,
          color: color,
        ),
      ),
    );
  }
}
