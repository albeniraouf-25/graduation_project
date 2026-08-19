import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import '../../core/resources/app_fonts.dart';
import '../../core/resources/app_values.dart';

class CustomTextFromField extends StatelessWidget {
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final Function()? onTap;
  final bool? obscureText;
  final bool? readOnly;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final bool unFocus;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final bool? filled;
  final Color? cursorColor;
  final Color? color;
  final Color? hintColor;
  final double? fontSize;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final double? contentPaddingTop;
  final double? contentPaddingStart;
  final double? contentPaddingEnd;
  final double? contentPaddingBottom;
  final double? borderRadius;
  final InputBorder? enableInputBorder;
  final InputBorder? errorInputBorder;
  final InputBorder? focusedInputBorder;
  final List<TextInputFormatter>? inputFormatters;
  final Function()? onTapOutside;
  final GlobalKey<FormState>? formKey;
  final bool expands;
  final String? initialValue;
  final FocusNode? focusNode;
  final double? cursorHeight;
  final void Function()? onEditingComplete;

  const CustomTextFromField({
    super.key,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.initialValue,
    this.textInputType,
    this.obscureText,
    this.prefixIcon,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.suffixIcon,
    this.hintText,
    this.hintColor,
    this.filled,
    this.cursorColor,
    this.focusNode,
    this.borderRadius,
    this.labelText,
    this.fontSize,
    this.readOnly,
    this.textDirection,
    this.textAlign,
    this.unFocus = true,
    this.onTap,
    this.controller,
    this.color,
    this.inputFormatters,
    this.onTapOutside,
    this.formKey,
    this.contentPaddingTop,
    this.contentPaddingStart,
    this.contentPaddingEnd,
    this.contentPaddingBottom,
    this.enableInputBorder,
    this.errorInputBorder,
    this.focusedInputBorder,
    this.cursorHeight,
    this.expands = false,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textDirection: textDirection,
      textAlign: textAlign ?? TextAlign.start,
      expands: expands,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      controller: controller,
      readOnly: readOnly ?? false,
      minLines: expands ? null : minLines,
      maxLines: expands ? null : maxLines,
      onTap: onTap,
      maxLength: maxLength,
      cursorOpacityAnimates: true,
      onEditingComplete: onEditingComplete,
      onTapOutside: (event) {
        onTapOutside?.call();
        if (unFocus) FocusManager.instance.primaryFocus!.unfocus();
        if (formKey != null) formKey!.currentState!.validate();
      },
      cursorWidth: 1.1.w,
      cursorHeight: cursorHeight ?? AppHeight.h25,
      initialValue: initialValue,
      textAlignVertical:  TextAlignVertical.top,
    
      onChanged: onChanged,
      focusNode: focusNode,
      cursorColor: cursorColor ?? context.appColors.primary,
      keyboardType: textInputType,
      obscureText: obscureText ?? false,
      style: Theme.of(
        context,
      ).textTheme.titleMedium!.copyWith(fontSize: fontSize ?? AppFontSize.s17, fontWeight: AppFontWeight.bold),
      validator: validator,

      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: (const InputDecoration())
          .applyDefaults(Theme.of(context).inputDecorationTheme)
          .copyWith(
        prefixIconConstraints:  BoxConstraints(
          minWidth:0,
          minHeight: 0,
        ), 
        errorStyle: Theme.of(
          context,
        ).textTheme.titleMedium!.copyWith(fontSize: AppFontSize.s12, color: context.appColors.red),
        border: InputBorder.none,
        enabledBorder:
        enableInputBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
              borderSide: BorderSide.none,
            ),
        focusedBorder:
        focusedInputBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
              borderSide: BorderSide.none,
            ),
        errorBorder:
        errorInputBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
              borderSide: BorderSide.none,
            ),
        focusedErrorBorder:
        errorInputBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
              borderSide: BorderSide.none,
            ),
        contentPadding: EdgeInsetsDirectional.only(
          top: contentPaddingTop ?? 0,
          start: contentPaddingStart ?? 0,
          end: contentPaddingEnd ?? 0,
          bottom: contentPaddingBottom ?? 0,
        ),
        alignLabelWithHint: true,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        prefixIcon: Padding(padding: EdgeInsetsDirectional.only(start: AppPaddingWidth.p15), child: prefixIcon),
        prefixIconColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.error)) {
            return context.appColors.red;
          }
          if (states.contains(WidgetState.focused)) {
            return context.appColors.primary;
          }

          return context.appColors.grey;
        }),
        suffixIcon: suffixIcon,
        filled: filled,
        fillColor: color,
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: hintColor ?? context.appColors.grey,
          fontSize: fontSize,
          fontWeight: AppFontWeight.regular,
        ),
        labelText: labelText,
        floatingLabelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.appColors.primary),
        labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.appColors.grey),
      ),
    );
  }
}
