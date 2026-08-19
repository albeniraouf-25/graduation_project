import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import '../../core/resources/app_values.dart';
import 'loading_widget.dart';

class CustomElevatedButton extends StatelessWidget {
  final Color? color;
  final Color? colorLoading;
  final BorderSide? borderSide;
  final double? width;
  final Widget? child;
  final double? elevation;
  final double? height;
  final double? marginTop;
  final double? marginBottom;
  final double? marginStart;
  final double? marginEnd;
  final double borderRadius;
  final Function() onPressed;
  final EdgeInsetsGeometry? padding;
  final bool? loading;
  final bool? notEnable;
  final Gradient? gradient;

  const CustomElevatedButton({
    super.key,
    required this.borderRadius,
    this.width,
    this.height,
    required this.onPressed,
    this.borderSide,
    this.elevation,
    this.child,
    this.padding,
    this.loading,
    this.notEnable,
    this.color,
    this.colorLoading,
    this.marginTop,
    this.marginBottom,
    this.marginStart,
    this.marginEnd,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
     absorbing: notEnable ?? false,
      child: Container(
        margin: EdgeInsetsDirectional.only(
          top: marginTop ?? 0,
          bottom: marginBottom ?? 0,
          start: marginStart ?? 0,
          end: marginEnd ?? 0,
        ),
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),

        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding,
            elevation: elevation,
            // visualDensity: const VisualDensity(
            //   horizontal: VisualDensity.minimumDensity,
            //   vertical: VisualDensity.minimumDensity,
            // ),
            backgroundColor: color ?? Colors.transparent,
            shadowColor: context.appColors.searchColor,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: borderSide ?? BorderSide.none,
            ),
          ),
          child: loading ?? false
              ? LoadingWidget2(
                  0,
                  color: colorLoading ?? context.appColors.white,
                  size: AppSize.s35,
                )
              : child,
        ),
      ),
    );
  }
}
