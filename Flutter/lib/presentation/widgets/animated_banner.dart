import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';

class AnimatedBanner extends StatefulWidget {
  final String message;

  const AnimatedBanner({super.key, required this.message});

  @override
  State<AnimatedBanner> createState() => AnimatedBannerState();
}

class AnimatedBannerState extends State<AnimatedBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppHeight.h30,
      left: AppWidth.w20,
      right: AppWidth.w20,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.appColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                   BoxShadow(
                    color: context.appColors.lightGrey,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SectionTitle(
                text: widget.message,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
