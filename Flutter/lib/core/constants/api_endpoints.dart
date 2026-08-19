class ApiEndpoints {
  const ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'https://api.atareeqak.tech/api';

  // Users
  static const String users = '/users';

  static const String create = '/create/';
  static const String verifyEmail = '/verify_email/';
  static const String resendVerification = '/resend_verification/';
  static const String login = '/login/';
  // مسار تجديد رمز الوصول (تحت /users)
  static const String refreshToken = '/refresh_token/';
  static const String forgotPassword = '/forgot_password/';
  static const String verifyResetCode = '/verify_reset_code/';
  static const String resendResetCode= '/resend_reset_code/';
  static const String resetPassword = '/reset_password/';
  static const String logout = '/logout/';

//////////////////////////////////////////////////////////////

  // Profile (under /users)
  static const String viewProfile = '/view_profile/';
  static const String updateDriverProfile = '/update_driver_profile/';
  static const String updateRiderProfile = '/update_rider_profile/';

  // Rides (base segment)
  static const String rides = '/rides';
  static const String ridesCreate = '/create/';
  static const String reservationsCreate = '/reservations/create/';
  static const String ridesSearch = '/search/';
  static const String myRides = '/my_rides/';
  static const String myReservations = '/my_reservations/';
  static String rideUpdate(int id) => '/$id/update/';
  static String rideCancel(int id) => '/$id/cancel/';
  static String rideDetails(int id) => '/ride_details/$id/';
  static String reservationCancel(int id) => '/reservations/$id/cancel/';
  static String reservationAccept(int id) => '/reservations/$id/accept/';
  static String reservationReject(int id) => '/reservations/$id/reject/';

  // Report (mounted at /api/reports/)
  static const String report = '/reports';
  static String reportUser(int id) => '/report/user/$id/';
  static String shareRides(int id) => '/shared_rides/$id/';
  static const String myReports = '/my_reports/';
  static String viewReportDetails(int id) => '/view_report_details/$id/';

  // Notifications
  static const String notifications = '/notifications';
  static const String registerDevice = '/register-device/';
  static const String notificationsList = '/';
  static const String notificationsReadAll = '/read-all/';
  static String notificationRead(int id) => '/$id/read/';

  // Payment
  static const String payments = '/payments';
  static const viewBalance = '/view_balance/';
  static const depositeRequest  = '/deposit_request/';
  static const viewDepositeRequests = '/view_deposit_requests/';
  static const viewTransaction = '/view_transactions/';
  static const pay = '/pay/';
}