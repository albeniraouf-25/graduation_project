import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import '../../presentation/widgets/custom_bottom_sheet.dart';
import '../../presentation/widgets/custom_elevated_button.dart';
import '../../presentation/widgets/text/body_title.dart';
import '../resources/app_values.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();

  factory ConnectionService() => _instance;

  ConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (result == ConnectivityResult.none) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          _showNoInternetBottomSheet(context);
        }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> _showNoInternetBottomSheet(BuildContext context) {
    return CustomBottomSheet.show(
      heightFactor: .28.h,
      context,
      title: "تحذير",
      body: Column(
        children: [
          const BodyTitle(
            text: 'لا يوجد اتصال بالإنترنت',
          ),
          CustomElevatedButton(
            marginTop: AppMarginHeight.m20,
            width: double.infinity,
            child: BodyTitle(
              text: "حسناً",
              overflow: TextOverflow.visible,
              color: context.appColors.white,
            ),
            color: context.appColors.primary,
            borderRadius: AppRadius.r15,
            onPressed: () {
              context.pop();
            },
          )
        ],
      ),
    );
  }
}
