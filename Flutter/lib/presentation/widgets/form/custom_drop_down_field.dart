import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/custom_drop_down_widget.dart';


import '../../../core/resources/app_fonts.dart';
import 'custom_input_field.dart';

class CustomDropDownField extends StatelessWidget {
  final String? title;
  final bool showInputField;
  final List<dynamic> dropDownItems;
  final ValueChanged<dynamic> onDropDownChanged;
  final String dropDownHint;
  final String? searchHintText;
  final String? initialValue;
  final String? inputHint;
  final TextEditingController? inputController;
  final bool requiredInput;
  final TextInputType? textInputType;
  final Function(String)? onChanged;
  final SingleSelectController<dynamic>? controller;
  final dynamic initialItem;

  const CustomDropDownField({
    super.key,
    this.title,
    this.showInputField = true,
    required this.dropDownItems,
    required this.onDropDownChanged,
    required this.dropDownHint,
    this.searchHintText,
    this.initialValue,
    this.textInputType,
    this.inputHint,
    this.inputController,
    this.requiredInput = true,
    this.onChanged,
    this.controller,
    this.initialItem,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = List<dynamic>.from(dropDownItems);


    if (controller != null) {
      final dynamic controllerValue = controller!.value;
      if (controllerValue != null && !items.contains(controllerValue)) {
        controller!.clear();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          RichText(
            overflow: TextOverflow.visible,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: context.appColors.primaryLight,
                    fontSize: AppFontSize.s15,
                  ),
                ),
                TextSpan(
                  text:requiredInput? ' *':'',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: context.appColors.red,
                    fontSize: AppFontSize.s18,
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomDropDownWidget(
                initialItem: initialItem,
                // color: AppColors.grey.withAlpha(40),
                color: context.appColors.backGround,
                searchHintText: searchHintText,
                onChanged: onDropDownChanged,
                hintText: dropDownHint,
                items: dropDownItems,
                isStringList: dropDownItems.every((item) => item is String),
                controller: controller,
              ),
            ),
            if (showInputField) ...[
              SizedBox(width: AppWidth.w7),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(top: AppPaddingHeight.p4),
                  child: CustomInputField(
                    initialValue: initialValue,
                    controller: inputController,
                    hintText: inputHint ?? "context.loc.enter_value_hint",
                    req: requiredInput,
                    textInputType: textInputType,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
