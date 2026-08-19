import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/custom_text_from_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';
import 'package:flutter/material.dart';

class FieldItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputType textInputType;
  final bool obscureText;
  final void Function(String)? onChanged;

  const FieldItem({
    super.key,
    required this.icon,
    required this.title,
    required this.labelText,
    this.validator,
    required this.textInputType,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: AppWidth.w5,
          children: [
            Icon(icon, color: context.appColors.primary),
            SectionTitle(
              text: title,
              color: context.appColors.primary,
              fontSize: AppFontSize.s16,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: AppPaddingHeight.p15),
          child: CustomTextFromField(
            maxLines: 1,
            contentPaddingStart: AppPaddingWidth.p17,
            enableInputBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16),
              borderSide: BorderSide(color: context.appColors.grey),
            ),
            focusedInputBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16),
              borderSide: BorderSide(color: context.appColors.primary),
            ),
            errorInputBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16),
              borderSide: BorderSide(color: context.appColors.red),
            ),
            labelText: labelText,
            validator: validator,
            cursorColor: context.appColors.primary,
            onChanged: onChanged,
            textInputType: textInputType,
            obscureText: obscureText,
            filled: false,
            borderRadius: AppRadius.r16,
          ),
        ),
      ],
    );
  }
}
