import 'package:a_tareqaak/core/extension/page_builder_extension.dart';
import 'package:a_tareqaak/core/utils/enums/enum_utils.dart';
import 'package:a_tareqaak/data/models/report/report_data_model.dart';
import 'package:a_tareqaak/data/models/rides/ride_data_model.dart';
import 'package:a_tareqaak/presentation/screens/auth/forgot_password_screen.dart';
import 'package:a_tareqaak/presentation/screens/auth/reset_password/reset_password_screen.dart';
import 'package:a_tareqaak/presentation/screens/customer_service/customer_service_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/delete_ride_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/edit_ride_list_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/edit_ride_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/my_rides_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/publish_ride_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/ride_details_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/driver_reservations_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/search_ride_form_screen.dart';
import 'package:a_tareqaak/presentation/screens/driver_rides/select_city_screen.dart';
import 'package:a_tareqaak/presentation/screens/home/widgets/driver_bottom_nav_bar.dart';
import 'package:a_tareqaak/presentation/screens/notifications/notifications_screen.dart';
import 'package:a_tareqaak/presentation/screens/profile/edit_user_profile_screen.dart';
import 'package:a_tareqaak/presentation/screens/profile/user_profile_screen.dart';
import 'package:a_tareqaak/presentation/screens/report/report_details_screen.dart';
import 'package:a_tareqaak/presentation/screens/report/my_reports_screen.dart';
import 'package:a_tareqaak/presentation/screens/report/send_report_screen.dart';
import 'package:a_tareqaak/presentation/screens/ride_tracking/ride_tracking_screen.dart';
import 'package:a_tareqaak/presentation/screens/rider_rides/my_reservations_screen.dart';
import 'package:a_tareqaak/presentation/screens/rider_rides/search_results_screen.dart';
import 'package:a_tareqaak/presentation/screens/rider_rides/widgets/rider_bottom_nav_bar.dart';
import 'package:a_tareqaak/presentation/screens/settings/settings_screen.dart';
import 'package:a_tareqaak/presentation/screens/splash/splash_screen.dart';
import 'package:a_tareqaak/presentation/screens/auth/login_screen.dart';
import 'package:a_tareqaak/presentation/screens/auth/register_screen.dart';
import 'package:a_tareqaak/presentation/screens/auth/check_code_screen.dart';
import 'package:a_tareqaak/presentation/screens/home/driver_home_screen.dart';
import 'package:a_tareqaak/presentation/screens/home/rider_home_screen.dart';
import 'package:a_tareqaak/presentation/screens/wallet/charge_wallet_screen.dart';
import 'package:a_tareqaak/presentation/screens/wallet/deposit_requests_screen.dart';
import 'package:a_tareqaak/presentation/screens/wallet/transaction_history_screen.dart';
import 'package:a_tareqaak/presentation/screens/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

//#region Splash
@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  final String? annualAuctionId;

  SplashRoute({this.annualAuctionId});

  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const SplashScreen().buildPage(pageAnimation: PageAnimation.fade);
  }
}

//#region Auth
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const LoginScreen().buildPage(pageAnimation: PageAnimation.fade);
  }
}

@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData with $RegisterRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const RegisterScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<CheckCodeRoute>(
  path: '/check-code',
)
class CheckCodeRoute extends GoRouteData with $CheckCodeRoute {
  final String email;
  final bool isForgotPassword;
  final String? resetToken;

  const CheckCodeRoute({
    required this.email,
    this.isForgotPassword = false,
    this.resetToken,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CheckCodeScreen(
      email: email,
      isForgotPassword: isForgotPassword,
      resetToken: resetToken,
    );
  }
}
//#endregion

//#region Home

class RiderHomeRoute extends GoRouteData with $RiderHomeRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const RiderHomeScreen();
  }
}

@TypedGoRoute<EditRideRoute>(path: '/edit-ride')
class EditRideRoute extends GoRouteData with $EditRideRoute {
  final RideDataModel $extra;

  const EditRideRoute({
    required this.$extra,
  });
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return EditRideScreen(ride: $extra).buildPage(pageAnimation: PageAnimation.slide);
  }
}


@TypedGoRoute<PublishRideRoute>(path: '/publish-ride')
class PublishRideRoute extends GoRouteData with $PublishRideRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const PublishRideScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<SelectCityRoute>(path: '/select-city')
class SelectCityRoute extends GoRouteData with $SelectCityRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const SelectCityScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<EditRideListRoute>(path: '/edit-ride-list')
class EditRideListRoute extends GoRouteData with $EditRideListRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const EditRideListScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}



@TypedGoRoute<DeleteRideRoute>(path: '/delete-ride')
class DeleteRideRoute extends GoRouteData with $DeleteRideRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const DeleteRideScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<RideDetailsRoute>(path: '/ride-details')
class RideDetailsRoute extends GoRouteData with $RideDetailsRoute {
  RideDetailsRoute({required this.$extra});

  
  final RideDataModel $extra;
  @override
  CustomTransitionPage buildPage(
      BuildContext context,
      GoRouterState state,
      ) {
    return RideDetailsScreen(
    ride: $extra,
    ).buildPage(
      pageAnimation: PageAnimation.slide,
    );
  }
}








@TypedGoRoute<CustomerServiceRoute>(path: '/customer-service')
class CustomerServiceRoute extends GoRouteData with $CustomerServiceRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const CustomerServiceScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<DriverProfileRoute>(path: '/driver-profile')
class DriverProfileRoute extends GoRouteData with $DriverProfileRoute {
  final bool? isOtherUser;
  final int? otherUserId;

  DriverProfileRoute({this.isOtherUser, this.otherUserId});

  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return UserProfileScreen(
      isOtherUser: isOtherUser ?? false,
      otherUserId: otherUserId,
    ).buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<EditDriverProfileRoute>(path: '/edit-driver-profile')
class EditDriverProfileRoute extends GoRouteData with $EditDriverProfileRoute {
  final bool? isMandatory;

  EditDriverProfileRoute({this.isMandatory});

  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return EditUserProfileScreen(isMandatory: isMandatory ?? false)
        .buildPage(pageAnimation: PageAnimation.slide);
  }
}

class DriverHomeRoute extends GoRouteData with $DriverHomeRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DriverHomeScreen();
  }
}

class DriverRidesRoute extends GoRouteData with $DriverRidesRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MyRidesScreen();
  }
}

class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const NotificationsScreen();
  }
}

class SettingsRoute extends GoRouteData with $SettingsRoute{
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  SettingsScreen();
  }
}

class RiderRidesRoute extends GoRouteData with $RiderRidesRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MyReservationsScreen();
  }
}

class RiderNotificationsRoute extends GoRouteData with $RiderNotificationsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const NotificationsScreen();
  }
}

class RiderSettingsRoute extends GoRouteData with $RiderSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsScreen();
  }
}

@TypedStatefulShellRoute<DriverShellRoute>(
  branches: [
    TypedStatefulShellBranch<DriverHomeBranch>(
      routes: [
        TypedGoRoute<DriverHomeRoute>(
          path: '/driver-home',
        ),
      ],
    ),

    TypedStatefulShellBranch<DriverRidesBranch>(
      routes: [
        TypedGoRoute<DriverRidesRoute>(
          path: '/my-rides',
        ),
      ],
    ),

    TypedStatefulShellBranch<NotificationsBranch>(
      routes: [
        TypedGoRoute<NotificationsRoute>(
          path: '/notifications',
        ),
      ],
    ),

    TypedStatefulShellBranch<SettingsBranch>(
      routes: [
        TypedGoRoute<SettingsRoute>(
          path: '/settings',
        ),
      ],
    ),
  ],
)
class DriverShellRoute extends StatefulShellRouteData {
  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return DriverShellScreen(
      navigationShell: navigationShell,
    );
  }
}



class DriverRidesBranch extends StatefulShellBranchData {}

class NotificationsBranch extends StatefulShellBranchData {}

class SettingsBranch extends StatefulShellBranchData {}

class DriverHomeBranch extends StatefulShellBranchData {}

class RiderHomeBranch extends StatefulShellBranchData {}

class RiderRidesBranch extends StatefulShellBranchData {}

class RiderNotificationsBranch extends StatefulShellBranchData {}

class RiderSettingsBranch extends StatefulShellBranchData {}


//#endregion


// Driver shell screen
class DriverShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DriverShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,

      bottomNavigationBar: DriverBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(index);
        },
      ),
    );
  }
}

@TypedGoRoute<SendReportRoute>(path: '/send-report')
class SendReportRoute extends GoRouteData with $SendReportRoute {
  final int userId;
  final int? rideId;

  const SendReportRoute({required this.userId, this.rideId});

  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return SendReportScreen(userId: userId, rideId: rideId)
        .buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<MyReportsRoute>(path: '/my-reports')
class MyReportsRoute extends GoRouteData with $MyReportsRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const MyReportsScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<ReportDetailsRoute>(path: '/report-details')
class ReportDetailsRoute extends GoRouteData with $ReportDetailsRoute {
  final ReportDataModel $extra;

  ReportDetailsRoute({required this.$extra});

  @override
  CustomTransitionPage buildPage(context, state) {
    return ReportDetailsScreen(
      report: $extra,
    ).buildPage(
      pageAnimation: PageAnimation.slide,
    );
 
 }
}

@TypedGoRoute<ResetPasswordRoute>(path: '/reset-password')
class ResetPasswordRoute extends GoRouteData with $ResetPasswordRoute {
  final String resetToken;

  ResetPasswordRoute({required this.resetToken});

  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return ResetPasswordScreen(resetToken: resetToken)
        .buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const ForgotPasswordScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

// إعداد مسارات الراكب وإتاحة شريط التنقل السفلي عبر StatefulShellRoute (typed)
@TypedStatefulShellRoute<RiderShellRoute>(
  branches: [
    TypedStatefulShellBranch<RiderHomeBranch>(
      routes: [
        TypedGoRoute<RiderHomeRoute>(
          path: '/rider-home',
        ),
      ],
    ),

    TypedStatefulShellBranch<RiderRidesBranch>(
      routes: [
        TypedGoRoute<RiderRidesRoute>(
          path: '/rider-rides',
        ),
      ],
    ),

    TypedStatefulShellBranch<RiderNotificationsBranch>(
      routes: [
        TypedGoRoute<RiderNotificationsRoute>(
          path: '/rider-notifications',
        ),
      ],
    ),

    TypedStatefulShellBranch<RiderSettingsBranch>(
      routes: [
        TypedGoRoute<RiderSettingsRoute>(
          path: '/rider-settings',
        ),
      ],
    ),
  ],
)
class RiderShellRoute extends StatefulShellRouteData {
  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return RiderShellScreen(
      navigationShell: navigationShell,
    );
  }
}

// Rider shell screen
class RiderShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const RiderShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: RiderBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

// مسارات المحفظة وبقية الشاشات
@TypedGoRoute<WalletRoute>(path: '/wallet')
class WalletRoute extends GoRouteData with $WalletRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const WalletScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<ChargeWalletRoute>(path: '/charge-wallet')
class ChargeWalletRoute extends GoRouteData with $ChargeWalletRoute {
  final String? method; // syriatel_cash / sham_cash

  ChargeWalletRoute({this.method});

  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return ChargeWalletScreen(method: method)
        .buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<TransactionHistoryRoute>(path: '/transaction-history')
class TransactionHistoryRoute extends GoRouteData
    with $TransactionHistoryRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const TransactionHistoryScreen()
        .buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<DepositRequestsRoute>(path: '/deposit-requests')
class DepositRequestsRoute extends GoRouteData with $DepositRequestsRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const DepositRequestsScreen()
        .buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<SearchRideFormRoute>(path: '/search-ride-form')
class SearchRideFormRoute extends GoRouteData with $SearchRideFormRoute {
  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return const SearchRideFormScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<SearchResultsRoute>(path: '/search-results')
class SearchResultsRoute extends GoRouteData with $SearchResultsRoute {
  final String? fromCity;
  final String? toCity;

  SearchResultsRoute({this.fromCity, this.toCity});

  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return SearchResultsScreen(
      location: fromCity,
      destination: toCity,
    ).buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<DriverReservationsRoute>(path: '/driver-reservations')
class DriverReservationsRoute extends GoRouteData with $DriverReservationsRoute {
 

  DriverReservationsRoute();

  @override
  CustomTransitionPage<void> buildPage(context, state) {
    return DriverReservationsScreen().buildPage(pageAnimation: PageAnimation.slide);
  }
}

@TypedGoRoute<RideTrackingRoute>(path: '/ride_tracking')
class RideTrackingRoute extends GoRouteData with $RideTrackingRoute {
  final RideDataModel $extra;
  final bool isDriver;

  RideTrackingRoute({required this.$extra, this.isDriver = false});

  @override
  CustomTransitionPage<void> buildPage(BuildContext context, GoRouterState state) {
    return RideTrackingScreen(
      ride: $extra,
      isDriver: isDriver,
    ).buildPage(pageAnimation: PageAnimation.slide);
  }
}