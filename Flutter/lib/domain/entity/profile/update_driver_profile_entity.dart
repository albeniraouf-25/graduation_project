import 'package:equatable/equatable.dart';

// كيان تحديث ملف السائق — كل الحقول اختيارية (تحديث جزئي)
class UpdateDriverProfileEntity extends Equatable {
  final String? name;
  final String? phone;
  final String? email;
  final String? carNumber;
  final String? carColor;
  // مسارات محلية للصور — تُرسل كملفات multipart وليست ضمن toJson
  final String? profilePicturePath;
  final String? carImagePath;

  const UpdateDriverProfileEntity({
    this.name,
    this.phone,
    this.email,
    this.carNumber,
    this.carColor,
    this.profilePicturePath,
    this.carImagePath,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) "name": name,
        if (phone != null) "phone": phone,
        if (email != null) "email": email,
        if (carNumber != null) "car_number": carNumber,
        if (carColor != null) "car_color": carColor,
      };

  @override
  List<Object?> get props =>
      [name, phone, email, carNumber, carColor, profilePicturePath, carImagePath];
}
