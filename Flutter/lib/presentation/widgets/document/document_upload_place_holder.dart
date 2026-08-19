import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import '../../../core/resources/app_values.dart';
import '../image_view.dart';
import '../text/section_title.dart';

class DocumentUploadPlaceholder extends StatelessWidget {
  final String? image;
  final bool isExpanded;
  final bool isVideo;
  final VoidCallback? onRemove;

  const DocumentUploadPlaceholder({
    super.key,
    required this.image,
    required this.isExpanded,
    this.isVideo = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      height: isExpanded ? AppHeight.h250 : AppHeight.h150,
      width: double.infinity,
      child: image != null
          ? Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: AppPaddingHeight.p13),
                  child: ImageView(
                    imagePath: image!,
                    height: isExpanded ? AppHeight.h210 : AppHeight.h110,
                    width: double.infinity,
                    radius: BorderRadius.circular(AppRadius.r15),
                    fit: isExpanded ? BoxFit.cover : BoxFit.fitWidth,
                  ),
                ),
                if (onRemove != null)
                  Positioned(
                    top: AppPaddingHeight.p6,
                    right: AppPaddingWidth.p6,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: FaIcon(
                        FontAwesomeIcons.circleXmark,
                        color: context.appColors.red,
                      ),
                      onPressed: onRemove,
                    ),
                  ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  isVideo ? FontAwesomeIcons.video : FontAwesomeIcons.camera,
                  color: context.appColors.grey,
                  size: AppSize.s42,
                ),
                SizedBox(height: AppHeight.h7),
                SectionTitle(
                  text: isVideo ? "أضف فيديو" : "أضف صورة",
                  color: context.appColors.greyText,
                ),
                SizedBox(height: AppHeight.h18),
              ],
            ),
    );
  }
}
