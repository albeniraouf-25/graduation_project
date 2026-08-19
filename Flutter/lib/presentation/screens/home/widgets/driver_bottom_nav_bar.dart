import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

// شريط التنقل السفلي لصفحات السائق مطابقة للتصميم المرفق
class DriverBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DriverBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;

    return Container(
      height: AppHeight.h70,
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.r20),
          topRight: Radius.circular(AppRadius.r20),
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            index: 0,
            icon: FontAwesomeIcons.house,
            label: tr.home,
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: FontAwesomeIcons.car,
            label: tr.my_rides,
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: FontAwesomeIcons.bell,
            label: tr.notifications,
          ),
          _buildNavItem(
            context,
            index: 3,
            icon: FontAwesomeIcons.gear,
            label: tr.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required FaIconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppHeight.h4,
        children: [
          FaIcon(
            icon,
            size: AppSize.s18,
            color: isSelected
                ? context.appColors.primary
                : context.appColors.greyText,
          ),
          BodyTitle(
            text: label,
            fontSize: AppFontSize.s11,
            fontWeight: isSelected ? AppFontWeight.bold : AppFontWeight.regular,
            color: isSelected
                ? context.appColors.primary
                : context.appColors.greyText,
          ),
        ],
      ),
    );
  }
}