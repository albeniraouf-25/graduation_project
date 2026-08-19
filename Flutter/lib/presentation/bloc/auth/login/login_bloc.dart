import 'dart:async';
import 'dart:developer';

import 'package:a_tareqaak/presentation/bloc/auth/login/i_login_event.dart';
import 'package:a_tareqaak/presentation/bloc/auth/login/i_login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_tareqaak/core/services/locator/locator.dart';
import 'package:a_tareqaak/data/data_source/auth/auth_storage_data_source.dart';
import 'package:a_tareqaak/data/models/auth/token/tokens_model.dart';
import 'package:a_tareqaak/core/utils/firebase_notifications_handler.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/domain/entity/auth/login/login_entity.dart';
import 'package:a_tareqaak/domain/usecase/i_use_case.dart';


// 👈 بلوك تسجيل الدخول المطابق للنموذج القياسي
class LoginBloc extends Bloc<ILoginEvent, ILoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginEvent>(_login);
  }

  FutureOr<void> _login(LoginEvent event, Emitter<ILoginState> emit) async {
    emit(LoginLoading());
    try {
      final result = await locator<
          IUseCase<BaseModel<TokensModel>?, LoginEntity>>(
        instanceName: 'LoginUseCase',
      )(event.entity);

      await result.fold(
        (l) async => emit(LoginFailed(l.message)),
        (r) async {
          // حفظ رمز الوصول حتى تعمل الطلبات المحمية (logout والخدمات الأخرى)
          final token = r?.data?.accessToken;

          if (token != null && token.isNotEmpty) {
            await locator<AuthStorageDataSource>().storeToken(token);
          }
          // حفظ رمز التحديث لتجديد رمز الوصول تلقائياً عند انتهائه
          final refreshToken = r?.data?.refreshToken;
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await locator<AuthStorageDataSource>().storeRefreshToken(refreshToken);
          }
          // حفظ نوع المستخدم لتوجيه الملف الشخصي للـ API الصحيح
          final userType = r?.data?.user?.userType;
          if (userType != null && userType.isNotEmpty) {
            await locator<AuthStorageDataSource>().storeUserType(userType);
          }
          // تسجيل رمز الجهاز (FCM) بالخادم الآن بعد توفّر رمز الوصول
          try {
            await FirebaseNotificationsHandler().registerTokenAfterLogin();
          } catch (e) {
            log('registerTokenAfterLogin failed: $e');
          }
          emit(LoginLoaded(tokensModel: r));
        },
      );
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      emit(LoginFailed(e.toString()));
    }
  }
}