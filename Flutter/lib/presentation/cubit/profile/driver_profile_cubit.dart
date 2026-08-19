import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_tareqaak/core/helper/media_picker_helper.dart';
import 'package:a_tareqaak/core/services/locator/locator.dart';
import 'package:a_tareqaak/data/data_source/auth/auth_storage_data_source.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/profile/profile_model.dart';
import 'package:a_tareqaak/domain/entity/profile/update_driver_profile_entity.dart';
import 'package:a_tareqaak/domain/entity/profile/update_rider_profile_entity.dart';
import 'package:a_tareqaak/domain/entity/profile/view_profile_entity.dart';
import 'package:a_tareqaak/domain/usecase/i_use_case.dart';
import 'driver_profile_state.dart';

// كيوبيت إدارة بروفايل السائق
class DriverProfileCubit extends Cubit<DriverProfileState> {
  DriverProfileCubit() : super(DriverProfileInitialState());

  final MediaPickerHelper _mediaPickerHelper = MediaPickerHelper();

  String driverName = 'أحمد علي';
  String phone = '0999 123 456';
  String carName = 'Kia Rio';
  String carColor = 'أبيض';
  String carPlate = '12-34567';
  String currentLocation = '';

  // نوع المستخدم الحالي (driver/rider) لتوجيه استدعاء الـ API الصحيح
  String? userType;
  bool get isRider => userType == 'rider';

  // القيمة الافتراضية تكون false للسائق الجديد
  bool isProfileComplete = false;

  String? profileImagePath;
  String? carCoverImagePath;

  // اختيار صورة البروفايل الشخصية ثم رفعها مباشرة
  Future<void> pickProfileImage(dynamic context) async {
    final imagePath = await _mediaPickerHelper.pickImage(context);
    if (imagePath != null) {
      profileImagePath = imagePath;
      emit(DriverProfileImagePickedState(
        profileImagePath: profileImagePath,
        carCoverImagePath: carCoverImagePath,
      ));
      await _uploadImages(profilePicturePath: imagePath);
    }
  }

  // اختيار صورة غلاف السيارة ثم رفعها مباشرة
  Future<void> pickCarCoverImage(dynamic context) async {
    final imagePath = await _mediaPickerHelper.pickImage(context);
    if (imagePath != null) {
      carCoverImagePath = imagePath;
      emit(DriverProfileImagePickedState(
        profileImagePath: profileImagePath,
        carCoverImagePath: carCoverImagePath,
      ));
      await _uploadImages(carImagePath: imagePath);
    }
  }

  // رفع الصورة (بروفايل و/أو غلاف السيارة) فقط دون بقية الحقول
  Future<void> _uploadImages({
    String? profilePicturePath,
    String? carImagePath,
  }) async {
    emit(DriverProfileImageUploadingState());
    try {
      final type = await _loadUserType();

      final result = type == 'rider'
          ? await locator<
                  IUseCase<BaseModel<dynamic>?, UpdateRiderProfileEntity>>(
              instanceName: 'UpdateRiderProfileUseCase',
            )(UpdateRiderProfileEntity(
              profilePicturePath: profilePicturePath,
            ))
          : await locator<
                  IUseCase<BaseModel<dynamic>?, UpdateDriverProfileEntity>>(
              instanceName: 'UpdateDriverProfileUseCase',
            )(UpdateDriverProfileEntity(
              profilePicturePath: profilePicturePath,
              carImagePath: carImagePath,
            ));

      result.fold(
        (l) => emit(DriverProfileImageUploadFailedState(l.message)),
        (r) {
          final serverError = r?.error;
          if (serverError != null && serverError.isNotEmpty) {
            emit(DriverProfileImageUploadFailedState(serverError));
            return;
          }
          emit(DriverProfileImageUploadedState());
        },
      );
    } catch (e) {
      emit(DriverProfileImageUploadFailedState(e.toString()));
    }
  }

  // قراءة نوع المستخدم من التخزين المحلي
  Future<String?> _loadUserType() async {
    if (userType != null) return userType;
    final result = await locator<AuthStorageDataSource>().getUserType();
    userType = result.fold((l) => null, (r) => r);
    return userType;
  }

  // للاستخدام من الواجهة لضبط نوع المستخدم قبل بناء الحقول
  Future<void> ensureUserTypeLoaded() => _loadUserType();

  // تحميل بيانات البروفايل من الخادم (view_profile) — يعمل للسائق والراكب
  Future<void> loadProfile() async {
    emit(DriverProfileLoadingState());
    try {
      await _loadUserType();
      final result = await locator<
          IUseCase<BaseModel<ProfileModel>?, ViewProfileEntity>>(
        instanceName: 'ViewProfileUseCase',
      )(const ViewProfileEntity());

      result.fold(
        (l) => emit(DriverProfileErrorState(l.message)),
        (r) {
          final profile = r?.data;
          if (profile != null) {
            driverName = profile.user?.name ?? driverName;
            phone = profile.user?.phone ?? phone;
            carName = profile.carModel ?? carName;
            carColor = profile.carColor ?? carColor;
            carPlate = profile.carNumber ?? carPlate;
            currentLocation = profile.currentLocation ?? currentLocation;
          }
          emit(DriverProfileLoadedState());
        },
      );
    } catch (e) {
      emit(DriverProfileErrorState(e.toString()));
    }
  }

  // تحديث البروفايل — يوجّه تلقائيًا لـ update_rider_profile أو update_driver_profile
  Future<void> updateProfile({
    required String name,
    required String phoneNum,
    String car = '',
    String color = '',
    String plate = '',
    String location = '',
  }) async {
    emit(DriverProfileLoadingState());
    try {
      final type = await _loadUserType();

      final result = type == 'rider'
          ? await locator<
                  IUseCase<BaseModel<dynamic>?, UpdateRiderProfileEntity>>(
              instanceName: 'UpdateRiderProfileUseCase',
            )(UpdateRiderProfileEntity(
              name: name,
              phone: phoneNum,
              currentLocation: location.isNotEmpty ? location : null,
              profilePicturePath: profileImagePath,
            ))
          : await locator<
                  IUseCase<BaseModel<dynamic>?, UpdateDriverProfileEntity>>(
              instanceName: 'UpdateDriverProfileUseCase',
            )(UpdateDriverProfileEntity(
              name: name,
              phone: phoneNum,
              carNumber: plate,
              carColor: color,
              profilePicturePath: profileImagePath,
              carImagePath: carCoverImagePath,
            ));

      result.fold(
        (l) => emit(DriverProfileErrorState(l.message)),
        (r) {
          // بعض أخطاء الخادم تعود داخل جسم الاستجابة (error)
          final serverError = r?.error;
          if (serverError != null && serverError.isNotEmpty) {
            emit(DriverProfileErrorState(serverError));
            return;
          }
          driverName = name;
          phone = phoneNum;
          if (type == 'rider') {
            currentLocation = location;
          } else {
            carName = car;
            carColor = color;
            carPlate = plate;
          }
          isProfileComplete = true;
          emit(DriverProfileSuccessState());
        },
      );
    } catch (e) {
      emit(DriverProfileErrorState(e.toString()));
    }
  }
}