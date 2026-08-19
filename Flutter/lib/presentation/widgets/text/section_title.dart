import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    this.text,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.overflow,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
    this.decorationThickness,
    this.height,
    this.maxLines,
  });

  final String? text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final TextDecorationStyle? decorationStyle;
  final Color? decorationColor;
  final double? decorationThickness;
  final double? height;

  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.titleMedium ?? const TextStyle();
    return Text(
      text ?? '',
      textAlign: textAlign,
      softWrap: true,
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines,
      style: baseStyle.copyWith(
        color: color ?? context.appColors.blackText,
        fontWeight: fontWeight ?? AppFontWeight.bold,
        fontSize: fontSize ?? AppFontSize.s16,
        decoration: decoration,
        decorationStyle: decorationStyle,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
        height: height,
      ),
    );
  }
}
