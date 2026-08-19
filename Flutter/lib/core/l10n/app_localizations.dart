import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'A Tareqaak'**
  String get app_name;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get welcome_back;

  /// No description provided for @login_to_access.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account'**
  String get login_to_access;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get email_hint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get password_hint;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dont_have_account;

  /// No description provided for @create_new_account.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get create_new_account;

  /// No description provided for @create_account_title.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get create_account_title;

  /// No description provided for @start_journey.
  ///
  /// In en, this message translates to:
  /// **'Create your account to start your journey with us'**
  String get start_journey;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get full_name_hint;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirm_password_hint;

  /// No description provided for @agree_terms.
  ///
  /// In en, this message translates to:
  /// **'I agree to Terms & Conditions and Privacy Policy'**
  String get agree_terms;

  /// No description provided for @create_account_btn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account_btn;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get already_have_account;

  /// No description provided for @enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enter_valid_email;

  /// No description provided for @enter_valid_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Syrian phone number'**
  String get enter_valid_phone;

  /// No description provided for @field_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get field_required;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_too_short;

  /// No description provided for @passwords_dont_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_dont_match;

  /// No description provided for @must_agree_terms.
  ///
  /// In en, this message translates to:
  /// **'You must agree to terms & conditions'**
  String get must_agree_terms;

  /// No description provided for @language_switch.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_switch;

  /// No description provided for @verify_email_title.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verify_email_title;

  /// No description provided for @verify_email_sub.
  ///
  /// In en, this message translates to:
  /// **'We sent a 5-digit verification code to'**
  String get verify_email_sub;

  /// No description provided for @resend_code_in.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resend_code_in;

  /// No description provided for @resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resend_code;

  /// No description provided for @verify_code_btn.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verify_code_btn;

  /// No description provided for @having_trouble_code.
  ///
  /// In en, this message translates to:
  /// **'Having trouble receiving the code? '**
  String get having_trouble_code;

  /// No description provided for @contact_us.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_us;

  /// No description provided for @invalid_otp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full 5-digit verification code'**
  String get invalid_otp;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @select_role_hint.
  ///
  /// In en, this message translates to:
  /// **'Select account type (Driver / Rider)'**
  String get select_role_hint;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @rider.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get rider;

  /// No description provided for @role_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a role to complete registration'**
  String get role_required;

  /// No description provided for @edit_ride_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Ride'**
  String get edit_ride_title;

  /// No description provided for @driver_home_title.
  ///
  /// In en, this message translates to:
  /// **'Driver Home'**
  String get driver_home_title;

  /// No description provided for @current_location.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get current_location;

  /// No description provided for @update_location.
  ///
  /// In en, this message translates to:
  /// **'Update location'**
  String get update_location;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @publish_ride.
  ///
  /// In en, this message translates to:
  /// **'Publish Ride'**
  String get publish_ride;

  /// No description provided for @edit_ride.
  ///
  /// In en, this message translates to:
  /// **'Edit Ride'**
  String get edit_ride;

  /// No description provided for @delete_ride.
  ///
  /// In en, this message translates to:
  /// **'Delete Ride'**
  String get delete_ride;

  /// No description provided for @quick_stats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quick_stats;

  /// No description provided for @active_rides.
  ///
  /// In en, this message translates to:
  /// **'Active Rides'**
  String get active_rides;

  /// No description provided for @completed_rides.
  ///
  /// In en, this message translates to:
  /// **'Completed Rides'**
  String get completed_rides;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @upcoming_rides.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Rides'**
  String get upcoming_rides;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all;

  /// No description provided for @publish_new_ride.
  ///
  /// In en, this message translates to:
  /// **'Publish New Ride'**
  String get publish_new_ride;

  /// No description provided for @departure_location.
  ///
  /// In en, this message translates to:
  /// **'Departure Location'**
  String get departure_location;

  /// No description provided for @select_departure_city.
  ///
  /// In en, this message translates to:
  /// **'Select departure city'**
  String get select_departure_city;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @select_destination.
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get select_destination;

  /// No description provided for @date_and_time.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get date_and_time;

  /// No description provided for @expected_duration.
  ///
  /// In en, this message translates to:
  /// **'Expected Duration'**
  String get expected_duration;

  /// No description provided for @three_hours.
  ///
  /// In en, this message translates to:
  /// **'3 Hours'**
  String get three_hours;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @syrian_pound.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get syrian_pound;

  /// No description provided for @available_seats.
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get available_seats;

  /// No description provided for @publish_ride_btn.
  ///
  /// In en, this message translates to:
  /// **'Publish Ride'**
  String get publish_ride_btn;

  /// No description provided for @select_city_title.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get select_city_title;

  /// No description provided for @search_city_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get search_city_hint;

  /// No description provided for @coastal_cities.
  ///
  /// In en, this message translates to:
  /// **'Coastal Cities'**
  String get coastal_cities;

  /// No description provided for @other_governorates.
  ///
  /// In en, this message translates to:
  /// **'Other Governorates'**
  String get other_governorates;

  /// No description provided for @editable_rides.
  ///
  /// In en, this message translates to:
  /// **'Editable Rides'**
  String get editable_rides;

  /// No description provided for @all_rides.
  ///
  /// In en, this message translates to:
  /// **'All Rides'**
  String get all_rides;

  /// No description provided for @edit_expired_badge.
  ///
  /// In en, this message translates to:
  /// **'Editing Deadline Expired'**
  String get edit_expired_badge;

  /// No description provided for @edit_expired_warning.
  ///
  /// In en, this message translates to:
  /// **'Trip cannot be edited less than 6 hours before departure'**
  String get edit_expired_warning;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @delete_ride_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Ride'**
  String get delete_ride_title;

  /// No description provided for @swipe_to_delete_hint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to delete trip'**
  String get swipe_to_delete_hint;

  /// No description provided for @delete_btn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_btn;

  /// No description provided for @confirm_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirm_delete_title;

  /// No description provided for @confirm_delete_msg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this trip?'**
  String get confirm_delete_msg;

  /// No description provided for @ride_published_success.
  ///
  /// In en, this message translates to:
  /// **'Trip published successfully'**
  String get ride_published_success;

  /// No description provided for @ride_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Trip edits saved successfully'**
  String get ride_updated_success;

  /// No description provided for @ride_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted successfully'**
  String get ride_deleted_success;

  /// No description provided for @location_updated.
  ///
  /// In en, this message translates to:
  /// **'Your current location has been updated successfully'**
  String get location_updated;

  /// No description provided for @available_seats_count.
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get available_seats_count;

  /// No description provided for @ride_details_title.
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get ride_details_title;

  /// No description provided for @departure_city.
  ///
  /// In en, this message translates to:
  /// **'Departure City'**
  String get departure_city;

  /// No description provided for @destination_city.
  ///
  /// In en, this message translates to:
  /// **'Destination City'**
  String get destination_city;

  /// No description provided for @trip_date.
  ///
  /// In en, this message translates to:
  /// **'Trip Date'**
  String get trip_date;

  /// No description provided for @trip_time.
  ///
  /// In en, this message translates to:
  /// **'Trip Time'**
  String get trip_time;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Expected Duration'**
  String get duration;

  /// No description provided for @seat_price.
  ///
  /// In en, this message translates to:
  /// **'Seat Price'**
  String get seat_price;

  /// No description provided for @driver_info.
  ///
  /// In en, this message translates to:
  /// **'Driver Information'**
  String get driver_info;

  /// No description provided for @location_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Unable to access your current location'**
  String get location_permission_denied;

  /// No description provided for @success_title.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success_title;

  /// No description provided for @error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_title;

  /// No description provided for @warning_title.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning_title;

  /// No description provided for @damascus.
  ///
  /// In en, this message translates to:
  /// **'Damascus'**
  String get damascus;

  /// No description provided for @rif_dimashq.
  ///
  /// In en, this message translates to:
  /// **'Rif Dimashq'**
  String get rif_dimashq;

  /// No description provided for @homs.
  ///
  /// In en, this message translates to:
  /// **'Homs'**
  String get homs;

  /// No description provided for @hama.
  ///
  /// In en, this message translates to:
  /// **'Hama'**
  String get hama;

  /// No description provided for @aleppo.
  ///
  /// In en, this message translates to:
  /// **'Aleppo'**
  String get aleppo;

  /// No description provided for @as_suwayda.
  ///
  /// In en, this message translates to:
  /// **'As-Suwayda'**
  String get as_suwayda;

  /// No description provided for @daraa.
  ///
  /// In en, this message translates to:
  /// **'Daraa'**
  String get daraa;

  /// No description provided for @quneitra.
  ///
  /// In en, this message translates to:
  /// **'Quneitra'**
  String get quneitra;

  /// No description provided for @deir_ez_zor.
  ///
  /// In en, this message translates to:
  /// **'Deir ez-Zor'**
  String get deir_ez_zor;

  /// No description provided for @al_hasakah.
  ///
  /// In en, this message translates to:
  /// **'Al-Hasakah'**
  String get al_hasakah;

  /// No description provided for @ar_raqqah.
  ///
  /// In en, this message translates to:
  /// **'Ar-Raqqah'**
  String get ar_raqqah;

  /// No description provided for @latakia.
  ///
  /// In en, this message translates to:
  /// **'Latakia'**
  String get latakia;

  /// No description provided for @jableh.
  ///
  /// In en, this message translates to:
  /// **'Jableh'**
  String get jableh;

  /// No description provided for @qardaha.
  ///
  /// In en, this message translates to:
  /// **'Qardaha'**
  String get qardaha;

  /// No description provided for @qadmous.
  ///
  /// In en, this message translates to:
  /// **'Qadmous'**
  String get qadmous;

  /// No description provided for @al_haffah.
  ///
  /// In en, this message translates to:
  /// **'Al-Haffah'**
  String get al_haffah;

  /// No description provided for @kasab.
  ///
  /// In en, this message translates to:
  /// **'Kasab'**
  String get kasab;

  /// No description provided for @ras_al_basit.
  ///
  /// In en, this message translates to:
  /// **'Ras Al-Basit'**
  String get ras_al_basit;

  /// No description provided for @tartus.
  ///
  /// In en, this message translates to:
  /// **'Tartus'**
  String get tartus;

  /// No description provided for @baniyas.
  ///
  /// In en, this message translates to:
  /// **'Baniyas'**
  String get baniyas;

  /// No description provided for @dreikish.
  ///
  /// In en, this message translates to:
  /// **'Dreikish'**
  String get dreikish;

  /// No description provided for @safita.
  ///
  /// In en, this message translates to:
  /// **'Safita'**
  String get safita;

  /// No description provided for @al_sheikh_badr.
  ///
  /// In en, this message translates to:
  /// **'Al-Sheikh Badr'**
  String get al_sheikh_badr;

  /// No description provided for @press_to_detect_location.
  ///
  /// In en, this message translates to:
  /// **'Tap to detect your current location'**
  String get press_to_detect_location;

  /// No description provided for @location_not_available.
  ///
  /// In en, this message translates to:
  /// **'location hasn\'t been set yet'**
  String get location_not_available;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @my_rides.
  ///
  /// In en, this message translates to:
  /// **'My Rides'**
  String get my_rides;

  /// No description provided for @my_reservations.
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get my_reservations;

  /// No description provided for @uncompleted.
  ///
  /// In en, this message translates to:
  /// **'Uncompleted'**
  String get uncompleted;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @driver_name.
  ///
  /// In en, this message translates to:
  /// **'Driver Name'**
  String get driver_name;

  /// No description provided for @share_ride.
  ///
  /// In en, this message translates to:
  /// **'Share Trip'**
  String get share_ride;

  /// No description provided for @view_profile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get view_profile;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get dark_mode;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @customer_service.
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get customer_service;

  /// No description provided for @my_reports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get my_reports;

  /// No description provided for @customer_service_title.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue / Customer Service'**
  String get customer_service_title;

  /// No description provided for @customer_service_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your issue and support team will contact you shortly'**
  String get customer_service_subtitle;

  /// No description provided for @describe_issue_hint.
  ///
  /// In en, this message translates to:
  /// **'Write the details here...'**
  String get describe_issue_hint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @report_received_title.
  ///
  /// In en, this message translates to:
  /// **'Report Received'**
  String get report_received_title;

  /// No description provided for @report_received_desc.
  ///
  /// In en, this message translates to:
  /// **'We will contact you after reviewing the issue.'**
  String get report_received_desc;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @joined_date.
  ///
  /// In en, this message translates to:
  /// **'Member since May 2026'**
  String get joined_date;

  /// No description provided for @contact_info.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contact_info;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @car_info.
  ///
  /// In en, this message translates to:
  /// **'Car Information'**
  String get car_info;

  /// No description provided for @car_name.
  ///
  /// In en, this message translates to:
  /// **'Car Name'**
  String get car_name;

  /// No description provided for @car_color.
  ///
  /// In en, this message translates to:
  /// **'Car Color'**
  String get car_color;

  /// No description provided for @car_plate.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get car_plate;

  /// No description provided for @edit_info.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get edit_info;

  /// No description provided for @edit_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_title;

  /// No description provided for @report_account.
  ///
  /// In en, this message translates to:
  /// **'Report Account'**
  String get report_account;

  /// No description provided for @report_account_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to report this account?'**
  String get report_account_confirm;

  /// No description provided for @complete_profile_mandatory.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile and car info to proceed using the app'**
  String get complete_profile_mandatory;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @contact_info_header.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contact_info_header;

  /// No description provided for @car_info_header.
  ///
  /// In en, this message translates to:
  /// **'Car Information'**
  String get car_info_header;

  /// No description provided for @car_type.
  ///
  /// In en, this message translates to:
  /// **'Car Type'**
  String get car_type;

  /// No description provided for @plate_number.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plate_number;

  /// No description provided for @car_id.
  ///
  /// In en, this message translates to:
  /// **'Car ID'**
  String get car_id;

  /// No description provided for @manufacturing_year.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing Year'**
  String get manufacturing_year;

  /// No description provided for @edit_profile_btn.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get edit_profile_btn;

  /// No description provided for @send_report_title.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get send_report_title;

  /// No description provided for @report_type_section.
  ///
  /// In en, this message translates to:
  /// **'1. Report Type'**
  String get report_type_section;

  /// No description provided for @choose_report_type_sub.
  ///
  /// In en, this message translates to:
  /// **'Choose the appropriate report type'**
  String get choose_report_type_sub;

  /// No description provided for @dangerous.
  ///
  /// In en, this message translates to:
  /// **'Dangerous'**
  String get dangerous;

  /// No description provided for @dangerous_sub.
  ///
  /// In en, this message translates to:
  /// **'Threat or danger to safety'**
  String get dangerous_sub;

  /// No description provided for @fake.
  ///
  /// In en, this message translates to:
  /// **'Fake'**
  String get fake;

  /// No description provided for @fake_sub.
  ///
  /// In en, this message translates to:
  /// **'Fake information or profile'**
  String get fake_sub;

  /// No description provided for @spam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get spam;

  /// No description provided for @spam_sub.
  ///
  /// In en, this message translates to:
  /// **'Unwanted spam messages'**
  String get spam_sub;

  /// No description provided for @harassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get harassment;

  /// No description provided for @harassment_sub.
  ///
  /// In en, this message translates to:
  /// **'Verbal or other harassment'**
  String get harassment_sub;

  /// No description provided for @inappropriate_content.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Content'**
  String get inappropriate_content;

  /// No description provided for @inappropriate_sub.
  ///
  /// In en, this message translates to:
  /// **'Content violating public morals'**
  String get inappropriate_sub;

  /// No description provided for @related_ride_section.
  ///
  /// In en, this message translates to:
  /// **'2. Trip Related to Issue (Optional)'**
  String get related_ride_section;

  /// No description provided for @select_ride_hint.
  ///
  /// In en, this message translates to:
  /// **'Select trip'**
  String get select_ride_hint;

  /// No description provided for @report_text_section.
  ///
  /// In en, this message translates to:
  /// **'3. Report Details'**
  String get report_text_section;

  /// No description provided for @explain_details_sub.
  ///
  /// In en, this message translates to:
  /// **'Please explain the problem in detail'**
  String get explain_details_sub;

  /// No description provided for @report_details_hint.
  ///
  /// In en, this message translates to:
  /// **'Write problem details here...'**
  String get report_details_hint;

  /// No description provided for @send_report_btn.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get send_report_btn;

  /// No description provided for @my_reports_title.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get my_reports_title;

  /// No description provided for @pending_status.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending_status;

  /// No description provided for @reviewed_status.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed_status;

  /// No description provided for @report_details_title.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get report_details_title;

  /// No description provided for @report_date.
  ///
  /// In en, this message translates to:
  /// **'Report Date'**
  String get report_date;

  /// No description provided for @related_ride.
  ///
  /// In en, this message translates to:
  /// **'Related Trip'**
  String get related_ride;

  /// No description provided for @report_text.
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get report_text;

  /// No description provided for @admin_notes.
  ///
  /// In en, this message translates to:
  /// **'Admin Notes'**
  String get admin_notes;

  /// No description provided for @close_btn.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close_btn;

  /// No description provided for @pick_image.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pick_image;

  /// No description provided for @report_type.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get report_type;

  /// No description provided for @reset_password_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_password_title;

  /// No description provided for @reset_password_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new strong password for your account'**
  String get reset_password_subtitle;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirm_new_password;

  /// No description provided for @save_new_password.
  ///
  /// In en, this message translates to:
  /// **'Save New Password'**
  String get save_new_password;

  /// No description provided for @password_reset_success.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully, please login now'**
  String get password_reset_success;

  /// No description provided for @rider_home_title.
  ///
  /// In en, this message translates to:
  /// **'Rider Home'**
  String get rider_home_title;

  /// No description provided for @search_ride_banner_title.
  ///
  /// In en, this message translates to:
  /// **'Search for a Ride'**
  String get search_ride_banner_title;

  /// No description provided for @search_ride_banner_sub.
  ///
  /// In en, this message translates to:
  /// **'Choose your destination and go easily'**
  String get search_ride_banner_sub;

  /// No description provided for @search_or_request_ride.
  ///
  /// In en, this message translates to:
  /// **'Search / Request Ride'**
  String get search_or_request_ride;

  /// No description provided for @available_rides_now.
  ///
  /// In en, this message translates to:
  /// **'Available Rides Now'**
  String get available_rides_now;

  /// No description provided for @no_data.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data;

  /// No description provided for @reservation_success.
  ///
  /// In en, this message translates to:
  /// **'Reservation created successfully'**
  String get reservation_success;

  /// No description provided for @currency_syp.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get currency_syp;

  /// No description provided for @available_seats_label.
  ///
  /// In en, this message translates to:
  /// **'seats available'**
  String get available_seats_label;

  /// No description provided for @book_btn.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book_btn;

  /// No description provided for @cancel_booking_btn.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancel_booking_btn;

  /// No description provided for @booking_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booking_confirmed;

  /// No description provided for @booking_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get booking_pending;

  /// No description provided for @booking_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get booking_cancelled;

  /// No description provided for @booking_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get booking_rejected;

  /// No description provided for @search_results_title.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get search_results_title;

  /// No description provided for @no_matching_rides.
  ///
  /// In en, this message translates to:
  /// **'No Matching Trips'**
  String get no_matching_rides;

  /// No description provided for @try_changing_time_or_dest.
  ///
  /// In en, this message translates to:
  /// **'Try changing the trip time or destination'**
  String get try_changing_time_or_dest;

  /// No description provided for @modify_search.
  ///
  /// In en, this message translates to:
  /// **'Modify Search'**
  String get modify_search;

  /// No description provided for @wallet_and_payment.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Payment'**
  String get wallet_and_payment;

  /// No description provided for @wallet_balance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get wallet_balance;

  /// No description provided for @charge_balance.
  ///
  /// In en, this message translates to:
  /// **'Charge Balance'**
  String get charge_balance;

  /// No description provided for @syriatel_cash.
  ///
  /// In en, this message translates to:
  /// **'Syriatel Cash'**
  String get syriatel_cash;

  /// No description provided for @sham_cash.
  ///
  /// In en, this message translates to:
  /// **'Sham Cash'**
  String get sham_cash;

  /// No description provided for @transaction_history.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transaction_history;

  /// No description provided for @sender_number.
  ///
  /// In en, this message translates to:
  /// **'Sender Number'**
  String get sender_number;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @other_amount.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other_amount;

  /// No description provided for @charge_request_submitted.
  ///
  /// In en, this message translates to:
  /// **'Recharge Request Submitted'**
  String get charge_request_submitted;

  /// No description provided for @charge_request_sub.
  ///
  /// In en, this message translates to:
  /// **'Please confirm transaction via Syriatel Cash app and balance will be added shortly'**
  String get charge_request_sub;

  /// No description provided for @waiting_approval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get waiting_approval;

  /// No description provided for @rejected_status.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected_status;

  /// No description provided for @accept_reservation.
  ///
  /// In en, this message translates to:
  /// **'Accept Reservation'**
  String get accept_reservation;

  /// No description provided for @reject_reservation.
  ///
  /// In en, this message translates to:
  /// **'Reject Reservation'**
  String get reject_reservation;

  /// No description provided for @reservation_accepted_success.
  ///
  /// In en, this message translates to:
  /// **'Reservation accepted successfully'**
  String get reservation_accepted_success;

  /// No description provided for @reservation_rejected_success.
  ///
  /// In en, this message translates to:
  /// **'Reservation rejected successfully'**
  String get reservation_rejected_success;

  /// No description provided for @pending_reservations_title.
  ///
  /// In en, this message translates to:
  /// **'Pending Reservations'**
  String get pending_reservations_title;

  /// No description provided for @pickup_location_label.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickup_location_label;

  /// No description provided for @no_pending_reservations.
  ///
  /// In en, this message translates to:
  /// **'No pending reservation requests'**
  String get no_pending_reservations;

  /// No description provided for @manage_reservations.
  ///
  /// In en, this message translates to:
  /// **'Manage Reservations'**
  String get manage_reservations;

  /// No description provided for @deposit_requests_title.
  ///
  /// In en, this message translates to:
  /// **'Deposit Requests'**
  String get deposit_requests_title;

  /// No description provided for @no_deposit_requests.
  ///
  /// In en, this message translates to:
  /// **'No deposit requests yet'**
  String get no_deposit_requests;

  /// No description provided for @no_transactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get no_transactions;

  /// No description provided for @charge_request_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit the recharge request'**
  String get charge_request_failed;

  /// No description provided for @approved_status.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved_status;

  /// No description provided for @trx_deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get trx_deposit;

  /// No description provided for @trx_payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get trx_payment;

  /// No description provided for @trx_earning.
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get trx_earning;

  /// No description provided for @trx_refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get trx_refund;

  /// No description provided for @wallet_history_only.
  ///
  /// In en, this message translates to:
  /// **'You can review your transaction history here.'**
  String get wallet_history_only;

  /// No description provided for @camera_permission_needed.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required.'**
  String get camera_permission_needed;

  /// No description provided for @gallery_permission_needed.
  ///
  /// In en, this message translates to:
  /// **'Gallery access permission is required.'**
  String get gallery_permission_needed;

  /// No description provided for @photo_shoot.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get photo_shoot;

  /// No description provided for @selection_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get selection_from_gallery;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
