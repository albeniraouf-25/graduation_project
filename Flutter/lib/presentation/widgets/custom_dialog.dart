import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';
import '../../core/resources/app_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final double borderRadius;
  final Color backgroundColor;
  final Color barrierColor;
  final Color statusBarColor;
  final Brightness statusBarIconBrightness;
  final Widget body;
  final bool canPop;
  final EdgeInsetsGeometry? padding;

  const CustomDialog({
    super.key,
    required this.title,
    required this.body,
    this.canPop = false,
    this.padding,
    this.borderRadius = 20.0,
    this.backgroundColor = Colors.white,
    this.barrierColor = Colors.black54,
    this.statusBarColor = Colors.transparent,
    this.statusBarIconBrightness = Brightness.dark,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SectionTitle(
                      text: title,
                      fontSize: AppFontSize.s14,
                    ),
                    const Spacer(),
                    if (canPop)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: FaIcon(
                          FontAwesomeIcons.timesCircle,
                          size: AppSize.s27,
                        ),
                      )
                  ],
                ),
                Divider(
                  color: context.appColors.lightBlack,
                  thickness: 0.1,
                  height: 20,
                ),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> show(
      BuildContext context, {
        required String title,
        required Widget body,
        bool canPop = false,
        Color barrierColor = Colors.black54,
        double borderRadius = 10.0,
        Color backgroundColor = Colors.white,
        Color statusBarColor = Colors.transparent,
        Brightness statusBarIconBrightness = Brightness.dark,
        EdgeInsetsGeometry? padding,
      }) {
    return showDialog(
      context: context,
      barrierColor: barrierColor,
      barrierDismissible: canPop,
      builder: (context) => CustomDialog(
        title: title,
        canPop: canPop,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        statusBarColor: statusBarColor,
        statusBarIconBrightness: statusBarIconBrightness,
        body: body,
        padding: padding,
      ),
    );
  }
}