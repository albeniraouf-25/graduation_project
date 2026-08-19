import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import '../../core/resources/app_fonts.dart';
import 'text/body_title.dart';

class CustomAvatar extends StatelessWidget {
  final String name;

  const CustomAvatar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.appColors.yellow,
        // color: Color.fromRGBO(name.codeUnitAt(0), name.codeUnitAt(0) ~/ 2, name.codeUnitAt(0) ~/ 3, 0.5),
      ),
      alignment: Alignment.center,
      child: BodyTitle(
        text: name[0],
        color: context.appColors.white,
        fontSize: AppFontSize.s40,
        fontWeight: AppFontWeight.medium,
      ),
    );
  }
}
