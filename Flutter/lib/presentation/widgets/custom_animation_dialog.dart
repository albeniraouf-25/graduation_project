import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import '../../core/resources/app_fonts.dart';

class CustomAnimationDialog {
  static Future<void> showDialog(
    BuildContext context, {
    required String message,
    Widget? messageWidget,
    String? okText,
    String? cancelText,
    bool? dismissOnBackKeyPress,
    Color? cancelColor,
    Color? okColor,
    VoidCallback? onOkPressed,
    VoidCallback? onCancelPressed,
    DialogType dialogType = DialogType.error,
  }) {
    return AwesomeDialog(
      useRootNavigator: true,

      dialogBackgroundColor: context.appColors.white,
      context: context,
      dismissOnBackKeyPress: dismissOnBackKeyPress ?? true,
      animType: AnimType.scale,
      dialogType: dialogType,
      dismissOnTouchOutside: dismissOnBackKeyPress ?? true,
      body: Center(
        child: messageWidget ??
            BodyTitle(
              textAlign: TextAlign.center,
              text: message,
              overflow: TextOverflow.visible,
              fontSize: AppFontSize.s15,
              fontWeight: AppFontWeight.medium,
            ),
      ),
      btnOkColor: okColor ?? context.appColors.primaryLight,
      btnCancelColor: cancelColor,
      btnCancelText: cancelText ?? "Cancel",
      btnOkText: okText ?? "Retry",
      btnCancelOnPress: onCancelPressed ?? () {},
      btnOkOnPress: onOkPressed,
    ).show();
  }
}
