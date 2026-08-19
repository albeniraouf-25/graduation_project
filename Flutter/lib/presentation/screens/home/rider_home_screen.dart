import 'package:a_tareqaak/data/models/ride/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_assets.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';

import 'package:a_tareqaak/presentation/screens/rider_rides/widgets/rider_ride_card_widget.dart';
import 'package:a_tareqaak/presentation/widgets/image_view.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class RiderHomeScreen extends StatelessWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppPaddingWidth.p20,
            vertical: AppPaddingHeight.p15,
          ),
          child: Column(
            spacing: AppHeight.h16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الشعار
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImageView(
                    imagePath: AppAssets.logo,
                    height: AppHeight.h45,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              // كارد البحث العلوي بخلفية AppAssets.defaultImage الجاهزة
              Container(
                height: AppHeight.h160,
                decoration: BoxDecoration(
                  color: context.appColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.r20),
                  image: DecorationImage(
                    image: AssetImage(AppAssets.defult),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      context.appColors.primary.withOpacity(0.85),
                      BlendMode.srcOver,
                    ),
                  ),
                ),
                padding: EdgeInsets.all(AppPaddingWidth.p20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppHeight.h12,
                  children: [
                    SectionTitle(
                      text: tr.search_ride_banner_title,
                      color: context.appColors.white,
                      fontSize: AppFontSize.s22,
                    ),
                    BodyTitle(
                      text: tr.search_ride_banner_sub,
                      color: context.appColors.white.withOpacity(0.9),
                      fontSize: AppFontSize.s13,
                    ),
                    InkWell(
                      onTap: () => context.push('/search-ride-form'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppPaddingWidth.p16,
                          vertical: AppPaddingHeight.p10,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BodyTitle(
                              text: tr.search_or_request_ride,
                              color: context.appColors.greyText,
                            ),
                            FaIcon(
                              FontAwesomeIcons.magnifyingGlass,
                              size: AppSize.s16,
                              color: context.appColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // عنوان رحلات متاحة الآن
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionTitle(
                    text: tr.available_rides_now,
                    fontSize: AppFontSize.s16,
                  ),
                  BodyTitle(
                    text: tr.view_all,
                    fontSize: AppFontSize.s13,
                    color: context.appColors.primary,
                  ),
                ],
              ),

              // كروت الرحلات بدون صورة واسم السائق
              RiderRideCardWidget(
                ride: RideModel(
                  id: '1',
                  departureCity: 'اللاذقية',
                  destinationCity: 'دمشق',
                  departureDateTime: DateTime(2026, 8, 15, 8, 30),
                  duration: '3 ساعات',
                  price: 50000,
                  availableSeats: 4,
                ),
                onBookTap: () {
                  context.push('/search-results');
                },
                onTapCard: () {
                  context.push(
                    '/ride-details',
                    extra: RideModel(
                      id: '1',
                      departureCity: 'اللاذقية',
                      destinationCity: 'دمشق',
                      departureDateTime: DateTime(2026, 8, 15, 8, 30),
                      duration: '3 ساعات',
                      price: 50000,
                      availableSeats: 4,
                    ),
                  );
                },
              ),
              RiderRideCardWidget(
                ride: RideModel(
                  id: '2',
                  departureCity: 'طرطوس',
                  destinationCity: 'حلب',
                  departureDateTime: DateTime(2026, 8, 16, 7, 0),
                  duration: '2.5 ساعة',
                  price: 40000,
                  availableSeats: 3,
                ),
                onBookTap: () {
                  context.push('/search-results');
                },
                onTapCard: () {
                  context.push(
                    '/ride-details',
                    extra: RideModel(
                      id: '2',
                      departureCity: 'طرطوس',
                      destinationCity: 'حلب',
                      departureDateTime: DateTime(2026, 8, 16, 7, 0),
                      duration: '2.5 ساعة',
                      price: 40000,
                      availableSeats: 3,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}