import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:a_tareqaak/core/resources/app_assets.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

class NoResultWidget extends StatelessWidget {
  final String title;

  const NoResultWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            width: AppWidth.w150,
            height: AppHeight.h150,
            alignment: AlignmentDirectional.center,
            AppAssets.noResult,
          ),
          SizedBox(height: AppHeight.h20),
          BodyTitle(
            text: title ,
            color: context.appColors.primary,
          )
        ],
      ),
    );
  }
}
