import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import '../../core/resources/app_values.dart';
import 'text/section_title.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;

  final Color barrierColor;
  final double heightFactor;
  final double borderRadius;
  final Color backgroundColor;
  final Color statusBarColor;
  final Brightness statusBarIconBrightness;
  final Widget body;
  final bool isScroll;
  final bool canPop;
  final EdgeInsetsGeometry? padding;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.borderRadius,
    required this.body,
    this.padding,
    this.barrierColor = Colors.black54,
    this.heightFactor = 1,
    this.backgroundColor = Colors.white,
    this.statusBarColor = Colors.transparent,
    this.isScroll = true,
    this.canPop = true,
    this.statusBarIconBrightness = Brightness.dark,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    //final keyboardHeight = mediaQuery.viewInsets.bottom;

    return PopScope(
      canPop: canPop,
      child: SafeArea(
        child: AnimatedContainer(
          // height: mediaQuery.size.height * heightFactor + keyboardHeight - 140.h,
          height: mediaQuery.size.height * heightFactor,
          duration: const Duration(milliseconds: 170),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(borderRadius),
                topLeft: Radius.circular(borderRadius),
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsetsDirectional.only(
                      top: AppPaddingHeight.p10,
                    ),
                    width: AppWidth.w132,
                    height: AppHeight.h7,
                    decoration: BoxDecoration(
                      color: context.appColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppRadius.r35),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: AppPaddingHeight.p17,
                    start: AppPaddingWidth.p20,
                    end: AppPaddingWidth.p20,
                    bottom: AppPaddingHeight.p17,
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      if (canPop)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.r18),
                            onTap: () => context.pop(context),
                            child: Container(
                              width: AppWidth.w52,
                              height: AppHeight.h52,
                              decoration: BoxDecoration(
                                color: context.appColors.white,
                                border: Border.all(color: context.appColors.greyDivider),
                                borderRadius: BorderRadius.circular(AppRadius.r18),
                              ),
                              child: Icon(Icons.close, color: context.appColors.primary),
                            ),
                          ),
                        ),

                      Center(child: SectionTitle(text: title)),
                    ],
                  ),
                ),
                Divider(
                  color: context.appColors.lightBlack,
                  thickness: 0.1,
                  height: 0,
                ),
                Expanded(
                  child: isScroll
                      ? CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: padding ?? const EdgeInsets.all(20.0),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    body,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: padding ?? const EdgeInsets.all(20.0),
                          child: body,
                        ),
                ),
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
    Color barrierColor = Colors.black54,
    double heightFactor = 0.955,
    double borderRadius = 20.0,
    bool enableDrag = true,
    bool isDismissible = true,
    bool canPop = true,
    Color backgroundColor = Colors.white,
    Color statusBarColor = Colors.transparent,
    Brightness statusBarIconBrightness = Brightness.dark,
    required Widget body,
    EdgeInsetsGeometry? padding,
    bool isScroll = true,
  }) {
    return showModalBottomSheet(
      barrierColor: barrierColor.withOpacity(.5),
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => CustomBottomSheet(
        title: title,
        barrierColor: barrierColor,
        canPop: canPop,
        heightFactor: heightFactor,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        statusBarColor: statusBarColor,
        statusBarIconBrightness: statusBarIconBrightness,
        body: body,
        isScroll: isScroll,
        padding: padding,
      ),
    ).then(
      (value) => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: statusBarIconBrightness,
        ),
      ),
    );
  }
}
