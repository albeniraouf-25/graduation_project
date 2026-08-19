import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import '../../core/resources/app_values.dart';

class LoadingWidget2 extends StatelessWidget {
  final int index;
  final double? size;
  final bool noCenter;
  final Color? color;

  const LoadingWidget2(this.index, {super.key, this.size, this.noCenter = false, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: [
        const ThreeBounceWidgetsFactory(),
        const WaveSpinnerWidgetsFactory(),
      ][index].create().render(color: color ?? context.appColors.primary, size: size ?? AppSize.s50, noCenter: noCenter),
    );
  }
}

// SpinKitWaveSpinner

abstract interface class ILoading {
  Widget render({required Color color, required double size, required noCenter});
}

class ThreeBounce implements ILoading {
  const ThreeBounce();

  @override
  Widget render({required Color color, required double size, required noCenter}) {
    if (noCenter) {
      return SpinKitThreeBounce(
        color: color,
        size: size,
      );
    }
    return Center(
      child: SpinKitThreeBounce(
        color: color,
        size: size,
      ),
    );
  }
}

class WaveSpinner implements ILoading {
  const WaveSpinner();

  @override
  Widget render({required Color color, required double size, required noCenter}) {
    if (noCenter) {
      return SpinKitWaveSpinner(
        color: color,
        size: size,
      );
    }
    return Center(
      child: SpinKitWaveSpinner(
        color: color,
        size: size,
      ),
    );
  }
}

class ThreeBounceWidgetsFactory implements IWidgetsFactory {
  const ThreeBounceWidgetsFactory();

  @override
  String getTitle() => 'Three Bounce Loading Widget';

  @override
  ILoading create() => const ThreeBounce();
}

class WaveSpinnerWidgetsFactory implements IWidgetsFactory {
  const WaveSpinnerWidgetsFactory();

  @override
  String getTitle() => 'Wave Spinner Loading Widget';

  @override
  ILoading create() => const WaveSpinner();
}

abstract interface class IWidgetsFactory {
  String getTitle();

  ILoading create();
}

class LoadingWidget extends StatelessWidget {
  final int index;
  final double? size;
  final bool? noCenter;
  final Color? color;

  const LoadingWidget(this.index, {super.key, this.size, this.noCenter = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: AppWidth.w90,
        height: AppHeight.h90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: AppWidth.w90,
              height: AppHeight.h90,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                valueColor: AlwaysStoppedAnimation(context.appColors.primary),
              ),
            ),

            BodyTitle(
              text: 'qwafil',
              fontSize: AppFontSize.s16,
              fontWeight: FontWeight.w600,
              color: context.appColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
