import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:a_tareqaak/presentation/bloc/rides/reservation_action/accept_reservation_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/rides/reservation_action/i_accept_reservation_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/reservation_action/i_accept_reservation_state.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class DriverReservationsScreen extends StatelessWidget {
  const DriverReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReservationActionBloc(),
      child: const _DriverReservationsContent(),
    );
  }
}

class _DriverReservationsContent extends StatelessWidget {
  const _DriverReservationsContent();

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocListener<ReservationActionBloc, IReservationActionState>(
          listener: (context, state) {
            if (state is ReservationActionSuccess) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: state.message,
                contentType: ContentType.success,
              );
            } else if (state is ReservationActionFailed) {
              showCustomSnackBar(
                context: context,
                title: tr.error_title,
                message: state.message,
                contentType: ContentType.failure,
              );
            }
          },
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
                        FontAwesomeIcons.xmark,
                        color: context.appColors.blackText,
                        size: AppSize.s20,
                      ),
                    ),
                    SectionTitle(
                      text: "طلبات الحجز",
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
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(AppPaddingWidth.p20),
                  itemCount: 1, // يمكن ربطه بقائمة الحجوزات القادمة
                  separatorBuilder: (_, __) => SizedBox(height: AppHeight.h12),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(AppPaddingWidth.p16),
                      decoration: BoxDecoration(
                        color: context.appColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r16),
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.primary.withOpacity(0.08),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        spacing: AppHeight.h10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SectionTitle(
                                text: "طلب حجز من راكب",
                                fontSize: AppFontSize.s16,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppPaddingWidth.p8,
                                  vertical: AppPaddingHeight.p4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.primary.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r6),
                                ),
                                child: BodyTitle(
                                  text: "معلّق",
                                  fontSize: AppFontSize.s12,
                                  color: context.appColors.primary,
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          BodyTitle(
                            text: "مكان التجمع: اللاذقية - ساحة أ any",
                            fontSize: AppFontSize.s13,
                            color: context.appColors.greyText,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomElevatedButton(
                                height: AppHeight.h40,
                                borderRadius: AppRadius.r10,
                                color: context.appColors.primary,
                                onPressed: () {
                                  context.read<ReservationActionBloc>().add(
                                        AcceptReservationEvent(
                                          const IdEntity(1),
                                        ),
                                      );
                                },
                                child: BodyTitle(
                                  text: "قبول الحجز",
                                  color: context.appColors.white,
                                  fontSize: AppFontSize.s13,
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ),
                              CustomElevatedButton(
                                height: AppHeight.h40,
                                borderRadius: AppRadius.r10,
                                color: context.appColors.lightRed,
                                borderSide:
                                    BorderSide(color: context.appColors.red),
                                onPressed: () {
                                  context.read<ReservationActionBloc>().add(
                                        RejectReservationEvent(
                                          const IdEntity(1),
                                        ),
                                      );
                                },
                                child: BodyTitle(
                                  text: "رفض الحجز",
                                  color: context.appColors.red,
                                  fontSize: AppFontSize.s13,
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}