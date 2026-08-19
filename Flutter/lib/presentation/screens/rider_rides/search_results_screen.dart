import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/domain/entity/rides/create_reservation_entity.dart';
import 'package:a_tareqaak/domain/entity/rides/search_rides_entity.dart';
import 'package:a_tareqaak/presentation/bloc/rides/create_reservation/create_reservation_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/rides/create_reservation/i_create_reservation_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/create_reservation/i_create_reservation_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/search_rides/i_search_rides_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/search_rides/i_search_rides_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/search_rides/search_rides_bloc.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SearchResultsScreen extends StatelessWidget {
  final String? location;
  final String? destination;

  const SearchResultsScreen({
    super.key,
    required this.location,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SearchRidesBloc()
            ..add(SearchRidesEvent(
              SearchRidesEntity(location: location, destination: destination),
            )),
        ),
        BlocProvider(
          create: (_) => CreateReservationBloc(),
        ),
      ],
      child: const _SearchResultsContent(),
    );
  }
}

class _SearchResultsContent extends StatelessWidget {
  const _SearchResultsContent();

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocListener<CreateReservationBloc, ICreateReservationState>(
          listener: (context, state) {
            if (state is CreateReservationLoaded) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: tr.reservation_success,
                contentType: ContentType.success,
              );
            } else if (state is CreateReservationFailed) {
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
                      text: tr.search_results_title,
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
                child: BlocBuilder<SearchRidesBloc, ISearchRidesState>(
                  builder: (context, state) {
                    if (state is SearchRidesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchRidesFailed) {
                      return Center(
                        child: BodyTitle(
                          text: state.message,
                          color: context.appColors.greyText,
                        ),
                      );
                    }
                    final rides = state is SearchRidesLoaded
                        ? state.response?.data?.rides ?? <RideDataModel>[]
                        : <RideDataModel>[];

                    if (rides.isEmpty) {
                      return Center(
                        child: BodyTitle(
                          text: tr.no_matching_rides,
                          color: context.appColors.greyText,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.all(AppPaddingWidth.p20),
                      itemCount: rides.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppHeight.h12),
                      itemBuilder: (context, index) {
                        final r = rides[index];
                        return Container(
                          padding: EdgeInsets.all(AppPaddingWidth.p16),
                          decoration: BoxDecoration(
                            color: context.appColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.r16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: AppHeight.h10,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SectionTitle(
                                    text: '${r.location} -> ${r.destination}',
                                    fontSize: AppFontSize.s16,
                                  ),
                                  SectionTitle(
                                    text: '${r.cost} ${tr.syrian_pound}',
                                    fontSize: AppFontSize.s14,
                                    color: context.appColors.primary,
                                  ),
                                ],
                              ),
                              BodyTitle(
                                text:
                                    '${r.departureDate} - ${r.departureTime}',
                                color: context.appColors.greyText,
                                fontSize: AppFontSize.s12,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.appColors.primary,
                                ),
                                onPressed: () {
                                  context.read<CreateReservationBloc>().add(
                                        CreateReservationEvent(
                                          CreateReservationEntity(
                                            ride: r.id ?? 0,
                                            pickupLocation: r.location ?? '',
                                          ),
                                        ),
                                      );
                                },
                                child: Text(
                                  tr.book_btn,
                                  style: TextStyle(color: context.appColors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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