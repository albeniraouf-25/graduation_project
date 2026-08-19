import 'package:a_tareqaak/core/constants/api_endpoints.dart';
import 'package:a_tareqaak/data/data_source/base/base_remote_data_source.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/profile/profile_model.dart';
import 'package:a_tareqaak/domain/entity/profile/update_driver_profile_entity.dart';
import 'package:a_tareqaak/domain/entity/profile/update_rider_profile_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:a_tareqaak/core/exceptions/app_exception.dart';

@Injectable()
class ProfileRemoteDataSource extends BaseRemoteDataSource<dynamic> {
  ProfileRemoteDataSource() : super(ApiEndpoints.users);

  // عرض الملف الشخصي (GET)
  Future<Either<AppException, BaseModel<ProfileModel>?>> viewProfile() {
    return fetchData<ProfileModel>(
      endpoint: ApiEndpoints.viewProfile,
      fromJsonT: (json) => ProfileModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // تحديث ملف السائق (PATCH)
  Future<Either<AppException, BaseModel<dynamic>?>> updateDriverProfile(
    UpdateDriverProfileEntity data,
  ) {
    final files = <Map<String, dynamic>>[
      if (data.profilePicturePath != null && data.profilePicturePath!.isNotEmpty)
        {'field_name': 'profile_picture', 'path': data.profilePicturePath},
      if (data.carImagePath != null && data.carImagePath!.isNotEmpty)
        {'field_name': 'car_image', 'path': data.carImagePath},
    ];
    final hasFiles = files.isNotEmpty;

    return patchData(
      endpoint: ApiEndpoints.updateDriverProfile,
      data: data.toJson(),
      // عند وجود صور نرسل الطلب كـ multipart، وإلا JSON عادي
      isFormData: hasFiles,
      files: hasFiles ? files : null,
    );
  }

  // تحديث ملف الراكب (PATCH)
  Future<Either<AppException, BaseModel<dynamic>?>> updateRiderProfile(
    UpdateRiderProfileEntity data,
  ) {
    final files = <Map<String, dynamic>>[
      if (data.profilePicturePath != null && data.profilePicturePath!.isNotEmpty)
        {'field_name': 'profile_picture', 'path': data.profilePicturePath},
    ];
    final hasFiles = files.isNotEmpty;

    return patchData(
      endpoint: ApiEndpoints.updateRiderProfile,
      data: data.toJson(),
      // عند وجود صورة نرسل الطلب كـ multipart، وإلا JSON عادي
      isFormData: hasFiles,
      files: hasFiles ? files : null,
    );
  }
}
