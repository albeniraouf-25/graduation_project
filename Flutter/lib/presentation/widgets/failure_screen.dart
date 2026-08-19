import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/resources/app_assets.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/core/services/locator/locator.dart';
//import 'package:a_tareqaak/data/data_sources/auth/auth_storage_data_source.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FailureScreen extends StatelessWidget {
  const FailureScreen({super.key, this.onPressed, this.errorMessage, this.height});

  final void Function()? onPressed;
  final String? errorMessage;

  final double? height;

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height:
            height ??
            (MediaQuery.of(context).size.height > 500 ? MediaQuery.of(context).size.height - AppHeight.h200 : 300),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppPaddingWidth.p15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                AppAssets.errorJson,
                width: AppWidth.w100,
                height: AppHeight.h100,
              ),
              SizedBox(height: AppHeight.h20),
              BodyTitle(
                text: errorMessage!.contains("Unauthenticated")
                    ? "إنتهت صلاحية الجلسة يرجى تسجيل الدخول مرة اخرى."
                    : errorMessage ?? "tr.title",
                fontWeight: AppFontWeight.bold,
                overflow: TextOverflow.visible,
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppHeight.h20),
              if (onPressed != null)
                CustomElevatedButton(
                  onPressed: /* errorMessage!.contains("Unauthenticated")
                      ? () async {
                          await locator<AuthStorageDataSource>().logout();
                          if (context.mounted) LoginRoute().go(context);
                        }
                      :  */onPressed!,
                  height: AppHeight.h50,
                  width: AppWidth.w200,
                  color: Colors.white,
                  borderSide: BorderSide(
                    color: context.appColors.primary,
                  ),
                  borderRadius: AppRadius.r9,
                  padding: EdgeInsets.symmetric(
                    vertical: AppPaddingHeight.p12,
                    horizontal: AppPaddingWidth.p25,
                  ),
                  child: BodyTitle(
                    text: errorMessage!.contains("Unauthenticated") ? context.loc.login : "tr.try_again",
                    color: context.appColors.primary,
                    fontSize: AppFontSize.s16,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
              SizedBox(height: AppHeight.h20),
            ],
          ),
        ),
      ),
    );
  }
}
