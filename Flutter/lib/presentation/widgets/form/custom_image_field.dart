import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'dart:ui' as ui;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomImageField extends StatelessWidget {
  final bool req;
  final Function()? onTap;
  final String hintText;
  final String? title;
  final ui.Image? image;

  const CustomImageField({
    super.key,
    this.req = false,
    required this.hintText,
    this.onTap,
    this.title,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppHeight.h4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          RichText(
            overflow: TextOverflow.visible,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: context.appColors.primary,
                        fontSize: AppFontSize.s15,
                      ),
                ),
                if (req)
                  TextSpan(
                    text: ' *',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: context.appColors.red,
                          fontSize: AppFontSize.s18,
                        ),
                  ),
              ],
            ),
          ),
        DottedBorder(
          padding: EdgeInsets.symmetric(
            vertical: image == null ? AppPaddingHeight.p60 : AppPaddingHeight.p5,
            horizontal: AppPaddingWidth.p5,
          ),
          strokeCap: StrokeCap.butt,
          dashPattern: const [3],
          color: context.appColors.lightBlack,
          borderType: BorderType.RRect,
          radius: Radius.circular(AppRadius.r16),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.r16),
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: onTap,
              child: Center(
                child: image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.image,
                            color: context.appColors.grey,
                            size: AppSize.s30,
                          ),
                          SizedBox(height: AppHeight.h7),
                          BodyTitle(
                            text: hintText,
                            color: context.appColors.greyText,
                          ),
                        ],
                      )
                    : SizedBox(
                        width: AppWidth.w45.isFinite ? double.infinity : 45,
                        height: AppHeight.h45.isFinite ? AppHeight.h220 : 45,
                        child: RawImage(
                          image: image,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
