import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';

class BodyTitle extends StatelessWidget {
  const BodyTitle({
    super.key,
     this.text,
    this.textAlign,
    this.color,
    this.fontSize,
    this.overflow,
    this.fontWeight,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
    this.decorationThickness,
    this.maxLines,
  });

  final String? text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final TextDecorationStyle? decorationStyle;
  final Color? decorationColor;
  final double? decorationThickness;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text ??'',
      softWrap: true,
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: color ?? context.appColors.blackText,
            fontSize: fontSize ?? AppFontSize.s14,
            fontWeight: fontWeight ?? AppFontWeight.medium,
            decoration: decoration,
            decorationStyle: decorationStyle,
            decorationColor: decorationColor,
            decorationThickness: decorationThickness,
          ),
    );
  }
}
