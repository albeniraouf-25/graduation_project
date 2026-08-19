import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: context.appColors.primary,
      child: child,
    );
  }
}