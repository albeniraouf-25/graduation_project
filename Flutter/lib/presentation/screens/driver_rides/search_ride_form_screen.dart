import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class SearchRideFormScreen extends StatefulWidget {
  const SearchRideFormScreen({super.key});

  @override
  State<SearchRideFormScreen> createState() => _SearchRideFormScreenState();
}

class _SearchRideFormScreenState extends State<SearchRideFormScreen> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppPaddingWidth.p20,
            vertical: AppPaddingHeight.p15,
          ),
          child: Column(
            spacing: AppHeight.h20,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: context.appColors.blackText,
                      size: AppSize.s20,
                    ),
                  ),
                  SectionTitle(
                    text: tr.search_or_request_ride,
                    fontSize: AppFontSize.s18,
                    fontWeight: AppFontWeight.bold,
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: FaIcon(
                      isRtl
                          ? FontAwesomeIcons.chevronRight
                          : FontAwesomeIcons.chevronLeft,
                      color: context.appColors.blackText,
                      size: AppSize.s20,
                    ),
                  ),
                ],
              ),

              // مكان الانطلاق (ينتقل فوراً لشاشة اختيار المدينة)
              CustomInputField(
                controller: _departureController,
                title: tr.departure_location,
                hintText: tr.select_departure_city,
                readOnly: true,
                isExpanded: true,
                onTap: () async {
                  final city = await context.push<String>('/select-city');
                  if (city != null) {
                    _departureController.text = city;
                  }
                },
                prefixIcon: Center(
                  widthFactor: 1.0,
                  child: FaIcon(
                    FontAwesomeIcons.locationDot,
                    color: context.appColors.grey,
                    size: AppSize.s18,
                  ),
                ),
              ),

              // الوجهة (ينتقل فوراً لشاشة اختيار المدينة)
              CustomInputField(
                controller: _destinationController,
                title: tr.destination,
                hintText: tr.select_destination,
                readOnly: true,
                isExpanded: true,
                onTap: () async {
                  final city = await context.push<String>('/select-city');
                  if (city != null) {
                    _destinationController.text = city;
                  }
                },
                suffixIcon: Center(
                  widthFactor: 1.0,
                  child: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    color: context.appColors.grey,
                    size: AppSize.s16,
                  ),
                ),
              ),

              const Spacer(),

              // زر البحث عن رحلة
              CustomElevatedButton(
                height: AppHeight.h50,
                width: double.infinity,
                borderRadius: AppRadius.r12,
                color: context.appColors.primary,
                onPressed: () {
                  SearchResultsRoute(
                    fromCity: _departureController.text.trim(),
                    toCity: _destinationController.text.trim(),
                  ).push(context);
                },
                child: BodyTitle(
                  text: tr.search,
                  color: context.appColors.white,
                  fontSize: AppFontSize.s16,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}