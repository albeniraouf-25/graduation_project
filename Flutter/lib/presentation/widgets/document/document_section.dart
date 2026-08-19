import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/resources/app_colors.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

import 'document_upload_place_holder.dart';

class DocumentSection extends StatelessWidget {
  final String? title;
  final String? supTitle;
  final String? image;
  final double? paddingTop;
  final double? paddingBottom;
  final VoidCallback onTap;
  final bool isExpanded;
  final bool isVideo;
  final bool isEnabled;
  final VoidCallback? onRemove;

  const DocumentSection({
    super.key,
    this.title,
    this.supTitle,
    required this.onTap,
    required this.image,
    this.paddingTop,
    this.paddingBottom,
    this.isExpanded = false,
    this.isVideo = false,
    this.isEnabled = true,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop ?? AppPaddingHeight.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            BodyTitle(
              text: title,
            ),
          if (supTitle != null) ...[
            SizedBox(height: AppHeight.h3),
            BodyTitle(
              text: supTitle,
              overflow: TextOverflow.visible,
              fontWeight: AppFontWeight.regular,
              fontSize: AppFontSize.s14,
            ),
          ],
          DottedBorder(
            borderPadding: EdgeInsets.only(
              top: AppPaddingHeight.p17,
              bottom: paddingBottom ?? AppPaddingHeight.p30,
            ),
            strokeCap: StrokeCap.butt,
            dashPattern: [3],
            color: context.appColors.lightBlack,
            borderType: BorderType.RRect,
            radius: Radius.circular(AppRadius.r16),
            padding: EdgeInsets.symmetric(vertical: AppPaddingHeight.p7, horizontal: AppPaddingWidth.p4),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(AppRadius.r16),
              ),
              child: InkWell(
                splashColor: AppColors.none,
                highlightColor: AppColors.none,
                onTap: isEnabled ? onTap : null,
                child: DocumentUploadPlaceholder(
                  image: image,
                  isExpanded: isExpanded,
                  isVideo: isVideo,
                  onRemove: onRemove,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
