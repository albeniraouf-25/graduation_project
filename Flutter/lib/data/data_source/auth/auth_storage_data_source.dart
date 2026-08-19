import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:a_tareqaak/core/constants/app_storage_paths.dart';
import '../../../core/exceptions/app_exception.dart';
import '../base/base_storage_data_source.dart';

@Injectable()
class AuthStorageDataSource extends BaseStorageDataSource {
  AuthStorageDataSource() : super(AppStoragePaths.auth);

  Future<Either<AppException, void>> logout() async {
    // حذف كلا الرمزين عند تسجيل الخروج
    await deleteData(key: AppStoragePaths.refreshToken);
    return deleteData(
      key: AppStoragePaths.token,
    );
  }

  Future<Either<AppException, dynamic>> storeToken(String? token) {
    return saveData(
      key: AppStoragePaths.token,
      data: token,
    );
  }

  Future<Either<AppException, String?>> getToken() {
    return getData(
      key: AppStoragePaths.token,
    ).then((e) => e.fold((l) => Left(l), (r) => Right(r as String?)));
  }

  // رمز التحديث (refresh token) — يُستخدم لتجديد رمز الوصول عند انتهائه
  Future<Either<AppException, dynamic>> storeRefreshToken(String? token) {
    return saveData(
      key: AppStoragePaths.refreshToken,
      data: token,
    );
  }

  Future<Either<AppException, String?>> getRefreshToken() {
    return getData(
      key: AppStoragePaths.refreshToken,
    ).then((e) => e.fold((l) => Left(l), (r) => Right(r as String?)));
  }

  // نوع المستخدم (driver/rider) لاستخدامه في توجيه الملف الشخصي
  Future<Either<AppException, dynamic>> storeUserType(String? userType) {
    return saveData(
      key: AppStoragePaths.userType,
      data: userType,
    );
  }

  Future<Either<AppException, String?>> getUserType() {
    return getData(
      key: AppStoragePaths.userType,
    ).then((e) => e.fold((l) => Left(l), (r) => Right(r as String?)));
  }

  Future<Either<AppException, dynamic>> storeRememberMe(bool rememberMe) {
    return saveData(
      key: AppStoragePaths.rememberMe,
      data: rememberMe,
    );
  }

  Future<Either<AppException, bool>> getRememberMe() {
    return getData(
      key: AppStoragePaths.rememberMe,
    ).then((e) => e.fold((l) => Left(l), (r) => Right(r ?? false)));
  }

  Future<Either<AppException, dynamic>> storeProfileComplete(bool profileComplete) {
    return saveData(
      key: AppStoragePaths.profileComplete,
      data: profileComplete,
    );
  }

  Future<Either<AppException, bool?>> getProfileComplete() {
    return getData(
      key: AppStoragePaths.profileComplete,
    ).then((e) => e.fold((l) => Left(l), (r) => Right(r as bool?)));
  }

  Future<Either<AppException, bool>> deleteProfileComplete() {
    return deleteData(
      key: AppStoragePaths.profileComplete,
    );
  }
}
