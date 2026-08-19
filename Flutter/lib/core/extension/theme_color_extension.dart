import 'package:flutter/material.dart';

import '../resources/app_colors.dart';

/// امتداد يوفّر ألوان التطبيق بشكل متجاوب مع الثيم (فاتح/داكن).
///
/// بدل استخدام `AppColors.primary` الثابتة داخل الواجهات — والتي تُظهر ألوان
/// الوضع الفاتح دائماً — استخدم `context.appColors.primary` فيتم اختيار اللون
/// المناسب تلقائياً حسب الثيم الحالي.
///
/// الأسماء هنا تطابق أسماء ألوان الوضع الفاتح في [AppColors] لتسهيل التحويل،
/// وتُرجع القيمة الداكنة المكافئة عندما يكون الثيم داكناً.
extension AppColorsContext on BuildContext {
  AppThemeColors get appColors =>
      AppThemeColors(Theme.of(this).brightness == Brightness.dark);
}

class AppThemeColors {
  final bool isDark;
  const AppThemeColors(this.isDark);

  // ================= الأساسية =================
  Color get primary => isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get primaryDark =>
      isDark ? AppColors.darkAccent : AppColors.primaryDark;
  Color get primaryLight =>
      isDark ? AppColors.darkAccent : AppColors.primaryLight;

  // اللون الثانوي (ذهبي) — علامة تجارية ثابتة في الوضعين
  Color get secondary => AppColors.secondary;
  Color get secondaryDark => AppColors.secondaryDark;
  Color get secondaryLight =>
      isDark ? AppColors.darkCard : AppColors.secondaryLight;
  Color get tertiary => isDark ? AppColors.darkDivider : AppColors.tertiary;

  // ================= الأسطح والخلفيات =================
  // white غالباً يُستخدم كخلفية بطاقة/سطح
  Color get white => isDark ? AppColors.darkCard : AppColors.white;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.surface;
  Color get backGround =>
      isDark ? AppColors.darkBackground : AppColors.backGround;
  Color get lightGrey => isDark ? AppColors.darkSurface : AppColors.lightGrey;
  Color get lightGreySec =>
      isDark ? AppColors.darkDivider : AppColors.lightGreySec;
  Color get greyButton => isDark ? AppColors.darkCard : AppColors.greyButton;
  Color get lightPrim => isDark ? AppColors.darkCard : AppColors.lightPrim;
  Color get lightPurple => isDark ? AppColors.darkCard : AppColors.lightPurple;
  Color get blueText => isDark ? AppColors.darkCard : AppColors.blueText;
  Color get blueBackGround =>
      isDark ? AppColors.darkSurface : AppColors.blueBackGround;
  Color get iconBackGround =>
      isDark ? AppColors.darkSurface : AppColors.iconBackGround;
  Color get lightBlue => isDark ? AppColors.darkSurface : AppColors.lightBlue;

  // ================= النصوص =================
  Color get blackText =>
      isDark ? AppColors.darkTextPrimary : AppColors.blackText;
  Color get black => isDark ? AppColors.darkTextPrimary : AppColors.black;
  Color get lightBlack =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightBlack;
  Color get blackCow =>
      isDark ? AppColors.darkTextSecondary : AppColors.blackCow;
  Color get greyText => isDark ? AppColors.darkTextSecondary : AppColors.greyText;
  Color get ofWhite => isDark ? AppColors.darkTextHint : AppColors.ofWhite;

  // ================= الرمادي والحدود =================
  Color get grey => isDark ? AppColors.darkIcon : AppColors.grey;
  Color get greyMan => isDark ? AppColors.darkIcon : AppColors.greyMan;
  Color get greySec => isDark ? AppColors.darkDivider : AppColors.greySec;
  Color get greyDivider =>
      isDark ? AppColors.darkDivider : AppColors.greyDivider;

  // ================= ألوان الحالة (ثابتة تقريباً في الوضعين) =================
  Color get red => isDark ? AppColors.darkError : AppColors.red;
  Color get lightRed => AppColors.lightRed;
  Color get green => isDark ? AppColors.darkSuccess : AppColors.green;
  Color get darkGreen => isDark ? AppColors.darkSuccess : AppColors.darkGreen;
  Color get lightGreen => AppColors.lightGreen;
  Color get orange => AppColors.orange;
  Color get lightOrange => isDark ? AppColors.darkCard : AppColors.lightOrange;
  Color get logoOrange => AppColors.logoOrange;
  Color get yellow => AppColors.yellow;
  Color get searchColor => AppColors.searchColor;
  Color get blackShadow =>
      isDark ? AppColors.black : AppColors.blackShadow;

  // شفاف — نفس القيمة دائماً
  Color get none => AppColors.none;
}
