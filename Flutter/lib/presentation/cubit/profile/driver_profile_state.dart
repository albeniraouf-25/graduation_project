import 'package:flutter/foundation.dart';

// الكلاس الأساسي المجرد لحالات بروفايل السائق
@immutable
abstract class DriverProfileState {}

class DriverProfileInitialState extends DriverProfileState {}

class DriverProfileLoadingState extends DriverProfileState {}

class DriverProfileImagePickedState extends DriverProfileState {
  final String? profileImagePath;
  final String? carCoverImagePath;

  DriverProfileImagePickedState({
    this.profileImagePath,
    this.carCoverImagePath,
  });
}

class DriverProfileSuccessState extends DriverProfileState {}

// حالات رفع الصورة (بروفايل/غلاف السيارة) مباشرة بعد اختيارها
class DriverProfileImageUploadingState extends DriverProfileState {}

class DriverProfileImageUploadedState extends DriverProfileState {}

class DriverProfileImageUploadFailedState extends DriverProfileState {
  final String message;

  DriverProfileImageUploadFailedState(this.message);
}

class DriverProfileLoadedState extends DriverProfileState {}

class DriverProfileErrorState extends DriverProfileState {
  final String message;

  DriverProfileErrorState(this.message);
}