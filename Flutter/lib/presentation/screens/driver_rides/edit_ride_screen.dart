import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';

import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/core/routes/app_routes.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/domain/entity/rides/update_ride_entity.dart';
import 'package:a_tareqaak/presentation/bloc/rides/update_ride/i_update_ride_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/update_ride/i_update_ride_state.dart';
import 'package:a_tareqaak/presentation/bloc/rides/update_ride/update_ride_bloc.dart';
import 'package:a_tareqaak/presentation/widgets/custom_elevated_button.dart';
import 'package:a_tareqaak/presentation/widgets/custom_snack_bar.dart';
import 'package:a_tareqaak/presentation/widgets/form/custom_input_field.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';

import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class EditRideScreen extends StatelessWidget {
  final RideDataModel? ride;

  const EditRideScreen({super.key, this.ride});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UpdateRideBloc(),
      child: _EditRideContent(ride: ride),
    );
  }
}

class _EditRideContent extends StatefulWidget {
  final RideDataModel? ride;

  const _EditRideContent({required this.ride});

  @override
  State<_EditRideContent> createState() => _EditRideContentState();
}

class _EditRideContentState extends State<_EditRideContent> {
  late final TextEditingController _departureController;
  late final TextEditingController _destinationController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;

  int _capacity = 4;

  @override
  void initState() {
    super.initState();
    _departureController = TextEditingController(text: widget.ride?.location ?? '');
    _destinationController = TextEditingController(text: widget.ride?.destination ?? '');
    _dateController = TextEditingController(text: widget.ride?.departureDate ?? '');
    _timeController = TextEditingController(text: widget.ride?.departureTime ?? '');
    _durationController = TextEditingController(text: widget.ride?.expectedDuration ?? '');
    _priceController = TextEditingController(text: widget.ride?.cost ?? '');
    _capacity = widget.ride?.capacity ?? 4;
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveChanges(BuildContext context) {
    debugPrint("widget.ride?.id = ${widget.ride?.id}");
    if (widget.ride?.id == null) return;

    final entity = UpdateRideEntity(
      id: widget.ride!.id!,
      location: _departureController.text.trim(),
      destination: _destinationController.text.trim(),
      departureDate: _dateController.text.trim(),
      departureTime: _timeController.text.trim(),
      expectedDuration: _durationController.text.trim(),
      cost: _priceController.text.trim(),
      capacity: _capacity,
    );

    context.read<UpdateRideBloc>().add(UpdateRideEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocListener<UpdateRideBloc, IUpdateRideState>(
          listener: (context, state) {
            if (state is UpdateRideLoaded) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: tr.ride_updated_success,
                contentType: ContentType.success,
              );
              context.pop(true);
            } else if (state is UpdateRideFailed) {
              showCustomSnackBar(
                context: context,
                title: tr.error_title,
                message: state.message,
                contentType: ContentType.failure,
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppPaddingWidth.p20,
              vertical: AppPaddingHeight.p15,
            ),
            child: Column(
              spacing: AppHeight.h16,
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
                      text: tr.edit_ride_title,
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

                CustomInputField(
                  controller: _departureController,
                  title: tr.departure_location,
                  hintText: tr.select_departure_city,
                  readOnly: true,
                  isExpanded: true,
                  onTap: () async {
                    final selectedCity = await SelectCityRoute().push<String>(context);
                    if (selectedCity != null) {
                      _departureController.text = selectedCity;
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

                CustomInputField(
                  controller: _destinationController,
                  title: tr.destination,
                  hintText: tr.select_destination,
                  readOnly: true,
                  isExpanded: true,
                  onTap: () async {
                    final selectedCity = await SelectCityRoute().push<String>(context);
                    if (selectedCity != null) {
                      _destinationController.text = selectedCity;
                    }
                  },
                ),

                Column(
                  spacing: AppHeight.h6,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      text: tr.date_and_time,
                      fontSize: AppFontSize.s14,
                      color: context.appColors.primary,
                    ),
                    Row(
                      spacing: AppWidth.w10,
                      children: [
                        Expanded(
                          child: CustomInputField(
                            controller: _dateController,
                            hintText: 'YYYY-MM-DD',
                            readOnly: true,
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (pickedDate != null) {
                                _dateController.text =
                                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: CustomInputField(
                            controller: _timeController,
                            hintText: 'HH:MM:SS',
                            readOnly: true,
                            showClock: true,
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                _timeController.text =
                                    "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                CustomInputField(
                  controller: _durationController,
                  title: tr.expected_duration,
                  hintText: tr.three_hours,
                  isExpanded: true,
                ),

                CustomInputField(
                  controller: _priceController,
                  title: tr.price,
                  hintText: '50000',
                  textInputType: TextInputType.number,
                  isExpanded: true,
                  prefixIcon: Center(
                    widthFactor: 1.0,
                    child: FaIcon(
                      FontAwesomeIcons.tag,
                      color: context.appColors.grey,
                      size: AppSize.s18,
                    ),
                  ),
                ),

                Column(
                  spacing: AppHeight.h6,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      text: tr.available_seats,
                      fontSize: AppFontSize.s14,
                      color: context.appColors.primary,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppPaddingWidth.p15,
                        vertical: AppPaddingHeight.p8,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r12),
                        border: Border.all(color: context.appColors.greyDivider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_capacity > 1) {
                                setState(() => _capacity--);
                              }
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.minus,
                              color: context.appColors.blackText,
                              size: AppSize.s16,
                            ),
                          ),
                          SectionTitle(
                            text: _capacity.toString(),
                            fontSize: AppFontSize.s18,
                            fontWeight: AppFontWeight.bold,
                          ),
                          IconButton(
                            onPressed: () {
                              if (_capacity < 8) {
                                setState(() => _capacity++);
                              }
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.plus,
                              color: context.appColors.blackText,
                              size: AppSize.s16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                BlocBuilder<UpdateRideBloc, IUpdateRideState>(
                  builder: (context, state) {
                    return CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: state is UpdateRideLoading,
                      onPressed: () => _saveChanges(context),
                      child: BodyTitle(
                        text: tr.save_changes,
                        color: context.appColors.white,
                        fontSize: AppFontSize.s16,
                        fontWeight: AppFontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}