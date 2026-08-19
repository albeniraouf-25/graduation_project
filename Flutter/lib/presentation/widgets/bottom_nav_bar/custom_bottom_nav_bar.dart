

import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/cubit/bottom_bar/bottom_bar_cubit.dart';
import 'package:a_tareqaak/presentation/widgets/bottom_nav_bar/custom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomBottomNavBar({super.key, required this.navigationShell});

  void _handleBranchTap(BuildContext context, int index) async {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;
    //final tr = context.loc;

    return BlocBuilder<BottomBarCubit, bool>(
      builder: (context, state) {
        return AnimatedContainer(

          alignment: Alignment.center,
          duration: const Duration(milliseconds: 250),
          height: state ? AppHeight.h120 : 0,
          curve: Curves.fastOutSlowIn,
          padding: EdgeInsetsDirectional.fromSTEB(
            AppPaddingWidth.p12,
            0,
            AppPaddingWidth.p12,
            0,
          ),
          color: context.appColors.none,
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppPaddingWidth.p12,
              AppPaddingHeight.p10,
              AppPaddingWidth.p12,
              AppPaddingHeight.p10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(
                color: const Color(0xFFE6E8EB),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.r20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  offset: Offset(0, 2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  onPressed: () => _handleBranchTap(context, 0),
                  icon: FontAwesomeIcons.house,
                  selectedIcon: FontAwesomeIcons.house,
                  label: "bar1",
                ),
                _buildNavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  onPressed: () => _handleBranchTap(context, 1),
                  icon: FontAwesomeIcons.tag,
                  selectedIcon: FontAwesomeIcons.tag,
                  label:"bar2",
                ),
                _buildNavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  onPressed: () => _handleBranchTap(context, 2),
                  icon: FontAwesomeIcons.scaleBalanced,
                  selectedIcon: FontAwesomeIcons.scaleBalanced,
                  label: "bar3",
                ),
                _buildNavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  onPressed: () => _handleBranchTap(context, 3),
                  icon: FontAwesomeIcons.briefcase,
                  selectedIcon: FontAwesomeIcons.briefcase,
                  label: "bar4",
                ),
                _buildNavItem(
                  index: 4,
                  currentIndex: currentIndex,
                  onPressed: () => _handleBranchTap(context, 4),
                  icon: FontAwesomeIcons.ellipsis,
                  selectedIcon: FontAwesomeIcons.ellipsis,
                  label: "bar5",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required VoidCallback onPressed,
    required FaIconData icon,
    required FaIconData selectedIcon,
    required String label,
  }) {
    final bool selected = index == currentIndex;
    return Expanded(
      child: CustomNavItem(
        onPressed: onPressed,
        icon: selected ? selectedIcon : icon,
        label: label,
        selected: selected,
      ).animate(target: selected ? null : 1).fadeIn(),
    );
  }
}
