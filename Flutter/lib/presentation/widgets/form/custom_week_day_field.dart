import 'package:flutter/material.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

class CustomWeekDayField extends StatelessWidget {
  final bool req;
  final String? title;

  const CustomWeekDayField({
    super.key,
    required this.req,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppHeight.h4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          RichText(
            overflow: TextOverflow.visible,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: context.appColors.primary,
                    fontSize: AppFontSize.s15,
                  ),
                ),
                if (req)
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
        WeekdaySelector(),
      ],
    );
  }
}

class WeekdaySelector extends StatefulWidget {
  const WeekdaySelector({super.key});

  @override
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  final List<String> _days = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  final Set<int> _selectedDays = {};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppWidth.w10,
      children: List.generate(_days.length, (index) {
        bool isSelected = _selectedDays.contains(index);
        return ChoiceChip(
          label: BodyTitle(
            text: _days[index],
            fontSize: AppFontSize.s13,
            color: isSelected ? Colors.white : Colors.black,
          ),
          selected: _selectedDays.contains(index),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(index);
              } else {
                _selectedDays.remove(index);
              }
            });
          },
          checkmarkColor: isSelected ? context.appColors.white : context.appColors.primary,
          backgroundColor: context.appColors.backGround,
          selectedColor: context.appColors.primary,
        );
      }),
    );
  }
}
