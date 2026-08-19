import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/presentation/widgets/custom_search.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class SelectCityScreen extends StatefulWidget {
  const SelectCityScreen({super.key});

  @override
  State<SelectCityScreen> createState() => _SelectCityScreenState();
}

class _SelectCityScreenState extends State<SelectCityScreen> {
  

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final List<String> coastalCities = [
     context.loc.latakia,
  context.loc.jableh,
  context.loc.qardaha,
  context.loc.qadmous,
  context.loc.al_haffah,
  context.loc.kasab,
  context.loc.ras_al_basit,
  context.loc.tartus,
  context.loc.baniyas,
  context.loc.dreikish,
  context.loc.safita,
  context.loc.al_sheikh_badr,
  ];

  final List<String> otherGovernorates = [
    context.loc.damascus,
  context.loc.rif_dimashq,
  context.loc.homs,
  context.loc.hama,
  context.loc.aleppo,
  context.loc.as_suwayda,
  context.loc.daraa,
  context.loc.quneitra,
  context.loc.deir_ez_zor,
  context.loc.al_hasakah,
  context.loc.ar_raqqah,
  ];
    final filteredCoastal = coastalCities
        .where((city) => city.contains(searchQuery.trim()))
        .toList();
    final filteredOther = otherGovernorates
        .where((city) => city.contains(searchQuery.trim()))
        .toList();

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPaddingWidth.p20,
                vertical: AppPaddingHeight.p15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  SectionTitle(
                    text: tr.select_city_title,
                    fontSize: AppFontSize.s18,
                    fontWeight: AppFontWeight.bold,
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: context.appColors.blackText,
                      size: AppSize.s20,
                    ),
                  ),
                ],
              ),
            ),

            // شريط البحث المطور
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPaddingWidth.p20),
              child: CustomSearch(
                color: context.appColors.white,
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPaddingWidth.p20,
                  vertical: AppPaddingHeight.p15,
                ),
                children: [
                  if (filteredCoastal.isNotEmpty) ...[
                    Center(
                      child: SectionTitle(
                        text: tr.coastal_cities,
                        fontSize: AppFontSize.s14,
                        color: context.appColors.primary,
                      ),
                    ),
                    SizedBox(height: AppHeight.h10),
                    Container(
                      decoration: BoxDecoration(
                        color: context.appColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                      ),
                      child: Column(
                        children: filteredCoastal
                            .map((city) => _buildCityItem(city))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: AppHeight.h20),
                  ],
                  if (filteredOther.isNotEmpty) ...[
                    Center(
                      child: SectionTitle(
                        text: tr.other_governorates,
                        fontSize: AppFontSize.s14,
                        color: context.appColors.primary,
                      ),
                    ),
                    SizedBox(height: AppHeight.h10),
                    Container(
                      decoration: BoxDecoration(
                        color: context.appColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                      ),
                      child: Column(
                        children: filteredOther
                            .map((city) => _buildCityItem(city))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityItem(String cityName) {
    return InkWell(
      onTap: () {
        context.pop(cityName);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppPaddingWidth.p16,
          vertical: AppPaddingHeight.p12,
        ),
        child: Row(
          spacing: AppWidth.w12,
          children: [
            FaIcon(
              FontAwesomeIcons.locationDot,
              size: AppSize.s16,
              color: context.appColors.primary,
            ),
            BodyTitle(
              text: cityName,
              fontSize: AppFontSize.s15,
              fontWeight: AppFontWeight.medium,
            ),
          ],
        ),
      ),
    );
  }
} 

