import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';

class CustomDropDownWidget extends StatelessWidget {
  final ValueChanged<dynamic> onChanged;
  final String hintText;
  final String? searchHintText;
  final List<dynamic>? items;
  final Widget? prefixIcon;
  final bool isStringList;
  final double? height;
  final double? startPadding;
  final double? endPadding;
  final double? topPadding;
  final double? bottomPadding;
  final double? borderRadius;
  final Color? color;
  final SingleSelectController<dynamic>? controller;
  final dynamic initialItem;

  const CustomDropDownWidget({
    super.key,
    required this.onChanged,
    required this.hintText,
    required this.items,
    this.isStringList = false,
    this.prefixIcon,
    this.height,
    this.startPadding,
    this.endPadding,
    this.topPadding,
    this.bottomPadding,
    this.borderRadius,
    this.color,
    this.searchHintText,
    this.controller,
    this.initialItem,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? AppHeight.h50,
      child: CustomDropdown<dynamic>.search(
        controller: controller,
        searchHintText: searchHintText,
        onChanged: onChanged,
        initialItem: initialItem,
        closedHeaderPadding: EdgeInsets.only(
          right: startPadding ?? AppPaddingWidth.p10,
          left: endPadding ?? AppPaddingWidth.p10,
          bottom: bottomPadding ?? AppPaddingHeight.p12,
          top: topPadding ?? AppPaddingHeight.p11,
        ),
        decoration: CustomDropdownDecoration(
          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: context.appColors.grey,
            fontWeight: AppFontWeight.regular,
          ),
          listItemStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: context.appColors.blackCow,
            fontSize: AppFontSize.s16,

          ),
          headerStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: context.appColors.lightBlack,
            fontSize: AppFontSize.s16,
          ),
          closedBorder: Border.all(color: context.appColors.grey.withAlpha(40)),
          expandedBorder: Border.all(color: context.appColors.grey.withAlpha(40)),

          closedFillColor: color ?? context.appColors.backGround,
          prefixIcon: prefixIcon,
          closedBorderRadius: BorderRadius.circular(borderRadius ?? AppRadius.r13),
          expandedBorderRadius: BorderRadius.circular(AppRadius.r13),
        ),
        items: isStringList ? items : items!.map((e) => e.name!).toList(),
        hintText: hintText,
      ),
    );
  }
}
