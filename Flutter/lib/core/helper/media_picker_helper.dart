import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:a_tareqaak/core/extension/localization_extension.dart';

class MediaPickerHelper {
  final ImagePicker picker = ImagePicker();
  List<XFile> selectedImages = [];
  XFile? selectedImage;
  XFile? selectedVideo;

  Future<List<String>> pickImages() async {
    try {
      selectedImages = await picker.pickMultiImage();
      if (selectedImages.isEmpty) {
        debugPrint('No images selected.');
        return [];
      }
      return selectedImages.map((file) => file.path).toList();
    } catch (e) {
      debugPrint('Error picking images: $e');
      return [];
    }
  }

  Future<String?> pickImageFromCamera(BuildContext context) async {
    final permission = Permission.camera;
    final status = await permission.request();
    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        _showPermissionSnackBar(context, context.loc.camera_permission_needed);
      }
      return null;
    }

    try {
      // تصغير الصورة عند الالتقاط لتقليل استهلاك الذاكرة أثناء القص
      // (يمنع قتل النظام للتطبيق أثناء شاشة UCrop وخطأ "Reply already submitted")
      selectedImage = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (selectedImage != null) {
        // نستخدم الصورة المصغّرة مباشرة بدون image_cropper لتفادي انهيار
        // الحزمة الأصلي (Reply already submitted) عند إلغاء شاشة القص.
        return selectedImage!.path;
      } else {
        debugPrint('No image selected.');
        return null;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<String?> pickImageFromGallery(BuildContext context) async {
    final permission = Permission.photos;
    final status = await permission.request();
    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        _showPermissionSnackBar(context, context.loc.gallery_permission_needed);
      }
      return null;
    }

    try {
      // تصغير الصورة عند الاختيار لتقليل استهلاك الذاكرة أثناء القص
      // (يمنع قتل النظام للتطبيق أثناء شاشة UCrop وخطأ "Reply already submitted")
      selectedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (selectedImage != null) {
        // نستخدم الصورة المصغّرة مباشرة بدون image_cropper لتفادي انهيار
        // الحزمة الأصلي (Reply already submitted) عند إلغاء شاشة القص.
        return selectedImage!.path;
      } else {
        debugPrint('No image selected.');
        return null;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<String?> pickVideoFromGallery() async {
    try {
      selectedVideo = await picker.pickVideo(source: ImageSource.gallery);

      if (selectedVideo != null) {
        return selectedVideo!.path;
      } else {
        debugPrint('No video selected.');
        return null;
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }
  Future<String?> pickImage(BuildContext context) async {
    final tr = context.loc;
    final result = await showModalBottomSheet<String>(
      backgroundColor: context.appColors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r13)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: context.appColors.primary),
                title: BodyTitle(text: tr.photo_shoot, color: context.appColors.blueText),
                onTap: () {
                  Navigator.pop(context, 'camera');
                },
              ),
              Divider(color: context.appColors.greyDivider, height: 0, thickness: 0.7, endIndent: AppHeight.h20, indent: AppHeight.h20),
              ListTile(
                leading: Icon(Icons.photo_library, color: context.appColors.primary),
                title: BodyTitle(text: tr.selection_from_gallery, color: context.appColors.blueText),
                onTap: () {
                  Navigator.pop(context, 'gallery');
                },
              ),
            ],
          ),
        );
      },
    );

    if (result == 'camera') {
      return await pickImageFromCamera(context);
    } else if (result == 'gallery') {
      return await pickImageFromGallery(context);
    }
    return null;
  }

  void _showPermissionSnackBar(BuildContext context, String message) {
    showCustomSnackBar(
      context: context,
      title: context.loc.error_title,
      message: message,
      contentType: ContentType.failure,
    );
  }
}
