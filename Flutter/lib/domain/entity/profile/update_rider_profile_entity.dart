import 'package:equatable/equatable.dart';

// كيان تحديث ملف الراكب — كل الحقول اختيارية (تحديث جزئي)
class UpdateRiderProfileEntity extends Equatable {
  final String? name;
  final String? phone;
  final String? email;
  final String? currentLocation;
  // مسار محلي لصورة البروفايل — يُرسل كملف multipart وليس ضمن toJson
  final String? profilePicturePath;

  const UpdateRiderProfileEntity({
    this.name,
    this.phone,
    this.email,
    this.currentLocation,
    this.profilePicturePath,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) "name": name,
        if (phone != null) "phone": phone,
        if (email != null) "email": email,
        if (currentLocation != null) "current_location": currentLocation,
      };

  @override
  List<Object?> get props =>
      [name, phone, email, currentLocation, profilePicturePath];
}
