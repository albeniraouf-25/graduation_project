
import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_rides_driver/i_my_rides_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_rides_driver/i_my_rides_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/my_rides_driver/my_rides_bloc.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/widgets/ride_card_widget.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyRidesBloc()..add(const GetMyRidesEvent()),
      child: const _MyRidesContent(),
    );
  }
}

class _MyRidesContent extends StatefulWidget {
  const _MyRidesContent();

  @override
  State<_MyRidesContent> createState() => _MyRidesContentState();
}

class _MyRidesContentState extends State<_MyRidesContent> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;

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
              child: Center(
                child: SectionTitle(
                  text: tr.my_rides,
                  fontSize: AppFontSize.s18,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<MyRidesBloc, IMyRidesState>(
                builder: (context, state) {
                  if (state is MyRidesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MyRidesFailed) {
                    return Center(child: BodyTitle(text: state.message));
                  }
                  final rides = state is MyRidesLoaded
                      ? state.response?.data?.rides ?? <RideDataModel>[]
                      : <RideDataModel>[];

                  if (rides.isEmpty) {
                    return Center(child: BodyTitle(text: tr.no_data));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<MyRidesBloc>().add(const GetMyRidesEvent());
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.all(AppPaddingWidth.p20),
                      itemCount: rides.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppHeight.h12),
                      itemBuilder: (context, index) {
                        final r = rides[index];
                        return RideCardWidget(
                          fromCity: r.location ?? '',
                          toCity: r.destination ?? '',
                          dateAndPriceText:
                              '${r.departureDate ?? ''} ${r.departureTime ?? ''} | ${r.cost ?? ''} ${tr.currency_syp}',
                          seatsText:
                              '${r.availableSeats ?? 0} ${tr.available_seats_label}',
                          onTap: () {
                            RideDetailsRoute($extra: r).push(context);
                            //context.push('/ride-details', extra: r, id: r.id);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}