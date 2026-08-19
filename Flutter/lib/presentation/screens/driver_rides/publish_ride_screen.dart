import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/domain/entity/rides/create_ride_entity.dart';
import 'package:a_tareqaak/presentation/bloc/rides/create_ride/create_ride_bloc.dart';
import 'package:a_tareqaak/presentation/bloc/rides/create_ride/i_create_ride_event.dart';
import 'package:a_tareqaak/presentation/bloc/rides/create_ride/i_create_ride_state.dart';
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

class PublishRideScreen extends StatelessWidget {
  const PublishRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateRideBloc(),
      child: const _PublishRideContent(),
    );
  }
}

class _PublishRideContent extends StatefulWidget {
  const _PublishRideContent();

  @override
  State<_PublishRideContent> createState() => _PublishRideContentState();
}

class _PublishRideContentState extends State<_PublishRideContent> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  int _availableSeats = 4;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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

  void _submitRide(BuildContext context) {
    final tr = context.loc;
    if (_departureController.text.trim().isEmpty ||
        _destinationController.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _priceController.text.trim().isEmpty) {
      showCustomSnackBar(
        context: context,
        title: tr.error_title,
        message: tr.field_required,
        contentType: ContentType.failure,
      );
      return;
    }

    final formattedDate =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00";

    final entity = CreateRideEntity(
      location: _departureController.text.trim(),
      destination: _destinationController.text.trim(),
      departureDate: formattedDate,
      departureTime: formattedTime,
      expectedDuration: _durationController.text.trim().isEmpty
          ? null
          : _durationController.text.trim(),
      cost: _priceController.text.trim(),
      capacity: _availableSeats,
    );

    context.read<CreateRideBloc>().add(CreateRideEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: BlocListener<CreateRideBloc, ICreateRideState>(
          listener: (context, state) {
            if (state is CreateRideLoaded) {
              showCustomSnackBar(
                context: context,
                title: tr.success_title,
                message: tr.ride_published_success,
                contentType: ContentType.success,
              );
              context.pop(true);
            } else if (state is CreateRideFailed) {
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
                      text: tr.publish_new_ride,
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
                    final selectedCity = await context.push<String>('/select-city');
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
                    final selectedCity = await context.push<String>('/select-city');
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
                                _selectedDate = pickedDate;
                                _dateController.text =
                                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              }
                            },
                            prefixIcon: Center(
                              widthFactor: 1.0,
                              child: FaIcon(
                                FontAwesomeIcons.calendarDay,
                                color: context.appColors.grey,
                                size: AppSize.s18,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CustomInputField(
                            controller: _timeController,
                            hintText: 'HH:MM',
                            readOnly: true,
                            showClock: true,
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                _selectedTime = pickedTime;
                                _timeController.text = pickedTime.format(context);
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
                              if (_availableSeats > 1) {
                                setState(() => _availableSeats--);
                              }
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.minus,
                              color: context.appColors.blackText,
                              size: AppSize.s16,
                            ),
                          ),
                          SectionTitle(
                            text: _availableSeats.toString(),
                            fontSize: AppFontSize.s18,
                            fontWeight: AppFontWeight.bold,
                          ),
                          IconButton(
                            onPressed: () {
                              if (_availableSeats < 8) {
                                setState(() => _availableSeats++);
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

                BlocBuilder<CreateRideBloc, ICreateRideState>(
                  builder: (context, state) {
                    final isLoading = state is CreateRideLoading;
                    return CustomElevatedButton(
                      height: AppHeight.h50,
                      width: double.infinity,
                      borderRadius: AppRadius.r12,
                      color: context.appColors.primary,
                      loading: isLoading,
                      onPressed: () => _submitRide(context),
                      child: BodyTitle(
                        text: tr.publish_ride_btn,
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