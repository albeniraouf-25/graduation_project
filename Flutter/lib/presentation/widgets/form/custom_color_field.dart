import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';

class CustomColorField extends StatelessWidget {
  const CustomColorField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ColorPickerCubit(const Color(0xff443a49)),
      child: BlocBuilder<ColorPickerCubit, Color>(
        builder: (context, pickerColor) {
          return Column(
            spacing: AppHeight.h7,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                overflow: TextOverflow.visible,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "اللون",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: context.appColors.primary,
                        fontSize: AppFontSize.s15,
                      ),
                    ),
                    TextSpan(
                      text: ' *',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: context.appColors.red,
                        fontSize: AppFontSize.s18,
                      ),
                    ),
                  ],
                ),
              ),
              _buildColorPickerButton(context, pickerColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColorPickerButton(BuildContext context, Color pickerColor) {
    return Container(
      height: AppHeight.h50,
      margin: EdgeInsetsDirectional.only(bottom: AppMarginWidth.m25),
      padding: EdgeInsetsDirectional.symmetric(
        vertical: AppPaddingHeight.p7,
        horizontal: AppPaddingWidth.p8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: context.appColors.grey),
        borderRadius: BorderRadius.circular(AppRadius.r3),
      ),
      child: SizedBox(
        height: AppHeight.h20,
        width: double.infinity,

        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: pickerColor,
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _showColorPickerDialog(context),
          child: const SizedBox(),
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ColorPickerCubit>(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r20),
            ),
            contentPadding: EdgeInsetsDirectional.only(
              top: AppPaddingHeight.p20,
              end: AppPaddingWidth.p20,
              start: AppPaddingWidth.p20,
            ),
            backgroundColor: context.appColors.backGround,
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerAreaBorderRadius: BorderRadius.circular(AppRadius.r16),
                pickerColor: context.read<ColorPickerCubit>().state,
                onColorChanged: (color) => context.read<ColorPickerCubit>().changeColor(color),
                enableAlpha: true,
                displayThumbColor: true,
                paletteType: PaletteType.hsv,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Cubit for managing color picker state
class ColorPickerCubit extends Cubit<Color> {
  ColorPickerCubit(super.initialColor);

  void changeColor(Color color) {
    emit(color);
  }
}
