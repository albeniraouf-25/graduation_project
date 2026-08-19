import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/custom_text_from_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomInputField extends StatelessWidget {
  final bool req;
  final bool readOnly;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final bool unFocus;
  final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final Function()? onTapOutside;
  final String hintText;
  final String? title;
  final String? initialValue;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isSecure;
  final bool showPercentage;
  final bool showFlag;
  final bool showClock;
  final bool? isExpanded;
  final TextInputType? textInputType;

  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final double? height;
  final double? borderRadius;
  final double? fontSize;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    this.req = false,
    this.isSecure = false,
    this.readOnly = false,
    this.unFocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.textDirection,
    this.textAlign,
    required this.hintText,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTapOutside,
    this.title,
    this.initialValue,
    this.controller,
    this.showPercentage = false,
    this.showFlag = false,
    this.showClock = false,
    this.textInputType,
  
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.inputFormatters,
    this.isExpanded,
  }) : assert(
          (showPercentage ? 1 : 0) + (showClock ? 1 : 0) <= 1,
          'Only one of showPercentage, or showClock can be true',
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppHeight.h4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          RichText(
            overflow: TextOverflow.visible,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: AppFontSize.s12,
                    fontWeight: AppFontWeight.semiBold,
                    color: context.appColors.primaryLight,
                  ),
                ),
                if (req)
                  TextSpan(
                    text: ' *',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: context.appColors.red, fontSize: AppFontSize.s18),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: height ?? (isExpanded ?? false ? null : AppHeight.h48),
          child: showFlag
              ? Directionality(textDirection: TextDirection.ltr, child: _buildTextField(context))
              : _buildTextField(context),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return CustomTextFromField(
      onTapOutside: onTapOutside,
      
      onFieldSubmitted: onFieldSubmitted,
      textDirection: textDirection,
      textAlign: textAlign,
      fontSize: fontSize,
      onChanged: onChanged,
      unFocus: unFocus,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: isSecure,
      maxLength: maxLength,
      initialValue: initialValue,
      inputFormatters: inputFormatters ?? (showPercentage ? [PercentageInputFormatter()] : null),
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      // color: AppColors.grey.withAlpha(40),
      color: context.appColors.backGround,
      contentPaddingTop: AppPaddingHeight.p10,
      contentPaddingStart: AppPaddingWidth.p10,
      contentPaddingEnd: AppPaddingWidth.p10,
      textInputType: showFlag ? TextInputType.number : (textInputType ?? TextInputType.text),
      hintText: hintText,
      validator: validator,
      enableInputBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.r8),
        borderSide: BorderSide(color: context.appColors.greyDivider, width: 0.7),
      ),
      focusedInputBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.r8),
        borderSide: BorderSide(color: context.appColors.primary, width: 0.7),
      ),
      errorInputBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r8),
        borderSide: BorderSide(color: context.appColors.red),
      ),
      borderRadius: borderRadius ?? AppRadius.r8,
      prefixIcon: showFlag
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*Padding(
                   padding: EdgeInsetsDirectional.only(
                    start: AppPaddingWidth.p12,
                    end: AppPaddingWidth.p7,
                    top: AppPaddingHeight.p12,
                    bottom: AppPaddingHeight.p12,
                  ),
                  child: ImageView(
                   // imagePath: AppAssets.saudiFlag,
                    height: AppHeight.h25,
                    width: AppWidth.w25,
                    fit: BoxFit.cover,
                  ),
                ), */
                BodyTitle(
                  text: "+963",
                  fontSize: AppFontSize.s14,
                  fontWeight: AppFontWeight.bold,
                  color: context.appColors.black,
                ),
                SizedBox(width: AppWidth.w10),
              ],
            )
          : prefixIcon,
      suffixIcon:
          suffixIcon ??
          (showPercentage
              ? FaIcon(FontAwesomeIcons.percent, color: context.appColors.primary, size: AppSize.s20)
              : showClock
              ? Transform.translate(
                offset: const Offset(0, 12),
                child: FaIcon(FontAwesomeIcons.clock, color: context.appColors.primary, size: AppSize.s20))
              : null),
    );
  }
}

class PercentageInputFormatter extends TextInputFormatter {
  static const arabicToEnglishDigits = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  String convertToEnglishDigits(String input) {
    return input.split('').map((char) => arabicToEnglishDigits[char] ?? char).join();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    if (text.isEmpty) return newValue;

    // استبدال الأرقام العربية أو الهندية
    text = convertToEnglishDigits(text);

    // السماح برقم عشري واحد فقط
    if (RegExp(r'^(\d+)([.,])?(\d{0,2})?$').hasMatch(text)) {
      final normalized = text.replaceAll(',', '.');
      final double? value = double.tryParse(normalized);
      if (value != null && value >= 0 && value <= 100) {
        return newValue.copyWith(text: text);
      }
    }

    return oldValue;
  }
}
