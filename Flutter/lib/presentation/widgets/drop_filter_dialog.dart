import 'dart:ui';

import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:flutter/material.dart';


import '../../core/resources/app_values.dart';

void dropFilterDialog({
  required context,
  required double height,
  required Widget child,
  double width = 361,
  double? paddingHeight,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(AppRadius.r16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingHeight ?? AppPaddingHeight.p24),
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.r16),
                color: context.appColors.white,
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.primary.withOpacity(0.5),
                    blurRadius: 10,
                    //offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
