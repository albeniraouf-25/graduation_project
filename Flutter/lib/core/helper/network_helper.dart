import 'dart:developer';
import 'dart:io';

import 'package:a_tareqaak/data/data_source/auth/auth_storage_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:a_tareqaak/core/services/locator/locator.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/api_endpoints.dart';
import '../exceptions/api_exception.dart';
import '../utils/network_utils.dart';
import 'dart:convert';

@Injectable()
class NetworkHelper {
  late final Dio _dio;
  // Dio منفصل بدون معترضات لاستدعاء تجديد الرمز (تفادي الحلقات اللانهائية)
  late final Dio _refreshDio;
  void Function()? _onUserArchived;
  void Function()? _onSessionExpired;
  bool _archiveFlowHandled = false;
  bool _sessionExpiredFlowHandled = false;
  // مشاركة نفس عملية التجديد بين كل الطلبات المتزامنة التي تلقّت 401
  Future<String?>? _refreshInProgress;

  // Singleton pattern
  static final NetworkHelper _instance = NetworkHelper._internal();

  factory NetworkHelper() => _instance;

  NetworkHelper._internal() {
    _dio = _initializeDio();
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  Dio get dio => _dio;

  void setOnUserArchived(void Function() handler) {
    _onUserArchived = handler;
  }

  void setOnSessionExpired(void Function() handler) {
    _onSessionExpired = handler;
  }

  /// Initializes Dio with base options and interceptors.
  Dio _initializeDio() {
    final options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      headers: {'Accept': 'application/json'},
    );
    return Dio(options)
      ..interceptors.addAll([
        _createRefreshInterceptor(),
        _createLogger(),
        PrettyLoggerInterceptor(),
      ]);
  }

  /// معترض يجدّد رمز الوصول تلقائياً عند استلام 401 ثم يعيد تنفيذ الطلب.
  QueuedInterceptorsWrapper _createRefreshInterceptor() {
    return QueuedInterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        final requestPath = error.requestOptions.path;

        final shouldTryRefresh = error.response?.statusCode == 401 &&
            // لا نجدّد على طلبات المصادقة نفسها لتفادي الحلقات
            !requestPath.contains(ApiEndpoints.login) &&
            !requestPath.contains(ApiEndpoints.refreshToken) &&
            // نتفادى إعادة المحاولة أكثر من مرة لنفس الطلب
            error.requestOptions.extra['__retried__'] != true;

        if (!shouldTryRefresh) {
          return handler.next(error);
        }

        final newToken = await _refreshAccessToken();

        if (newToken == null || newToken.isEmpty) {
          // فشل التجديد ⇒ الجلسة منتهية فعلاً
          if (!_sessionExpiredFlowHandled) {
            _sessionExpiredFlowHandled = true;
            _onSessionExpired?.call();
          }
          return handler.next(error);
        }

        try {
          final options = error.requestOptions;
          options.extra['__retried__'] = true;
          options.headers['Authorization'] = 'Bearer $newToken';

          final response = await _dio.fetch<dynamic>(options);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      },
    );
  }

  /// يجدّد رمز الوصول باستخدام رمز التحديث المخزّن.
  /// يعيد رمز الوصول الجديد أو null عند الفشل. يشارك عملية واحدة بين الطلبات المتزامنة.
  Future<String?> _refreshAccessToken() {
    return _refreshInProgress ??= _performTokenRefresh()
      ..whenComplete(() => _refreshInProgress = null);
  }

  Future<String?> _performTokenRefresh() async {
    final authStorage = locator<AuthStorageDataSource>();
    final refreshToken =
        await authStorage.getRefreshToken().then((r) => r.fold((l) => null, (r) => r));

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '${ApiEndpoints.users}${ApiEndpoints.refreshToken}',
        data: {'refresh_token': refreshToken},
      );

      final body = response.data ?? const {};
      final newAccess = body['access_token'] as String?;
      final newRefresh = body['refresh_token'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        return null;
      }

      await authStorage.storeToken(newAccess);
      // OAuth2 يدوّر رمز التحديث في كل مرة، فنخزّن الجديد
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await authStorage.storeRefreshToken(newRefresh);
      }
      return newAccess;
    } on DioException catch (e, s) {
      log('Token refresh failed: ${e.message}');
      log(s.toString());
      return null;
    } catch (e, s) {
      log('Token refresh failed: $e');
      log(s.toString());
      return null;
    }
  }

  /// Creates a Dio interceptor for logging.
  PrettyDioLogger _createLogger() {
    return PrettyDioLogger(
      enabled: kDebugMode,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
      maxWidth: 120,
      request: true,
      error: true,
    );
  }

  /// Fetches the token from the local data source.
  Future<String?> getToken() async {
    return locator<AuthStorageDataSource>().getToken().then((result) => result.fold((l) => null, (r) => r));
  }

  /// Fetches the version, appName ..etc.

  Future<String?> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    // String buildNumber = packageInfo.buildNumber;
    return packageInfo.version;
  }

  /// Executes a GET request with optional query parameters.
  Future<Either<ApiException, Response<Map<String, dynamic>>>> get(
    String url, {
    Map<String, dynamic>? queryParams,
    dynamic data,
  }) async {
    final token = await getToken();
    final version = await getVersion();

    return _performRequest(() {
      return _dio.get<Map<String, dynamic>>(
        url,
        data: data,
        queryParameters: queryParams,
        options: Options(headers: _buildHeaders(token, version)),
      );
    });
  }

  /// Executes a POST request with optional data and files.
  Future<Either<ApiException, Response<Map<String, dynamic>>>> post(
    String url, {
    dynamic data,
    bool isFormDate = true,
    List<Map<String, dynamic>>? files,
     bool requiresAuth = true,
  }) async {
    final token = requiresAuth ? await getToken() : null;

    final version = await getVersion();

    final formData = isFormDate ? await _buildFormData(data, files) : data;

    return _performRequest(() {
      return _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: _buildHeaders(token, version, isMultipart: isFormDate)),
        data: formData,
      );
    });
  }

  Future<Either<ApiException, Response<Map<String, dynamic>>>> put(
    String url, {
    dynamic data,
    bool isFormDate = true,
    List<Map<String, dynamic>>? files,
  }) async {
    final token = await getToken();
    final version = await getVersion();

    final formData = isFormDate ? await _buildFormData(data, files) : data;

    return _performRequest(() {
      return _dio.put<Map<String, dynamic>>(
        url,
        options: Options(headers: _buildHeaders(token, version, isMultipart: isFormDate)),
        data: formData,
      );
    });
  }

  /// Executes a PATCH request with data and optional files.
  Future<Either<ApiException, Response<Map<String, dynamic>>>> patch(
    String url, {
    dynamic data,
    bool isFormData = true,
    Map<String, dynamic>? queryParams,
    List<Map<String, dynamic>>? files,
  }) async {
    final token = await getToken();
    final version = await getVersion();

    final payload = isFormData ? await _buildFormData(data, files) : data;

    return _performRequest(() {
      return _dio.patch<Map<String, dynamic>>(
        url,
        options: Options(headers: _buildHeaders(token, version, isMultipart: isFormData)),
        data: payload,
        queryParameters: queryParams,
      );
    });
  }

/*   Future<Either<ApiException, BaseModel<PaginationModel<T>>?>> patchPagination<T>({
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? data,
    bool isFormData = true,
    List<Map<String, dynamic>>? files,
    required T Function(Object? json) fromJsonT,
  }) async {
    try {
      final response = await patch(
        url,
        queryParams: queryParams,
        data: data,
        isFormData: isFormData,
        files: files,
      );
      return response.fold(
        (error) => Left(error),
        (right) => Right(
          BaseModel<PaginationModel<T>>.fromJson(
            right.data as Map<String, dynamic>,
            (json) => PaginationModel<T>.fromJson(json as Map<String, dynamic>, fromJsonT),
          ),
        ),
      );
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(e.toString(), dio.options.headers["lang"] ?? "ar"));
    }
  }
 */
  /// Executes a DELETE request with optional data.
  Future<Either<ApiException, Response<Map<String, dynamic>>>> delete(
    String url, {
    Map<String, dynamic>? queryParams,
    dynamic data,
    bool isFormData = false,
  }) async {
    final token = await getToken();
    final version = await getVersion();

    final payload = isFormData ? await _buildFormData(data, null) : data;

    return _performRequest(() {
      return _dio.delete<Map<String, dynamic>>(
        url,
        options: Options(headers: _buildHeaders(token, version, isMultipart: isFormData)),
        data: payload,
        queryParameters: queryParams,
      );
    });
  }

/*   Future<Either<ApiException, BaseModel<PaginationModel<T>>?>> deletePagination<T>({
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? data,
    bool isFormData = false,
    required T Function(Object? json) fromJsonT,
  }) async {
    try {
      final response = await delete(
        url,
        queryParams: queryParams,
        data: data,
        isFormData: isFormData,
      );
      return response.fold(
        (error) => Left(error),
        (right) => Right(
          BaseModel<PaginationModel<T>>.fromJson(
            right.data as Map<String, dynamic>,
            (json) => PaginationModel<T>.fromJson(json as Map<String, dynamic>, fromJsonT),
          ),
        ),
      );
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(e.toString(), dio.options.headers["lang"] ?? "ar"));
    }
  }
 */
  /// Performs an HTTP request and handles errors.
  Future<Either<ApiException, Response<Map<String, dynamic>>>> _performRequest(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    if (await NetworkUtils.checkInternet()) {
      try {
        final response = await request();
        return Right(response);
      } on DioException catch (e, s) {
        log(e.message.toString());
        log(s.toString());
        final responseData = e.response?.data;
        final isArchived = responseData is Map<String, dynamic> && responseData['is_archived'] == true;
        final hasSessionExpired = _isUnauthenticatedError(
          statusCode: e.response?.statusCode,
          responseData: responseData,
        );

        if (isArchived && !_archiveFlowHandled) {
          _archiveFlowHandled = true;
          _onUserArchived?.call();
        }
        if (hasSessionExpired && !_sessionExpiredFlowHandled) {
          _sessionExpiredFlowHandled = true;
          _onSessionExpired?.call();
        }

        return Left(_handleError(e.response?.statusCode, _extractErrorMessage(responseData)));
      } catch (e, s) {
        log(e.toString());
        log(s.toString());
        return Left(_handleError(0, 'Unexpected error occurred'));
      }
    } else {
      return Left(NoInternetConnectionException(lang: dio.options.headers["lang"] ?? "ar"));
    }
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return null;

    final errors = responseData['errors'];
    if (errors is String && errors.isNotEmpty) return errors;

    final message = responseData['message'];
    if (message is String && message.isNotEmpty) return message;

    return null;
  }

  bool _isUnauthenticatedError({required int? statusCode, required dynamic responseData}) {
    if (statusCode != 401 || responseData is! Map<String, dynamic>) {
      return false;
    }

    final message = responseData['message'];
    return message is String && message.trim().toLowerCase() == 'unauthenticated.';
  }

  /// Handles API exceptions based on the status code.
  ApiException _handleError(int? statusCode, String? message) {
    log("***************************************************");
    log("Status Code: $statusCode");
    log("Error Message: $message");
    log("***************************************************");

    switch (statusCode) {
      case 400:
        return BadRequestException(message ?? 'Bad request', dio.options.headers["lang"]);
      case 401:
        return UnauthorizedException(message ?? 'Unauthorized access', dio.options.headers["lang"]);
      case 403:
        return ForbiddenException(message ?? 'Access forbidden', dio.options.headers["lang"]);
      case 404:
        return NotFoundException(message ?? 'Resource not found', dio.options.headers["lang"]);
      case 422:
        return GeneralException(message ?? 'General Exception', dio.options.headers["lang"]);
      case 409:
        return DuplicatedException(message ?? 'Conflict: Email already in use', dio.options.headers["lang"]);
      case 500:
        return InternalServerErrorException(message ?? 'Internal server error', dio.options.headers["lang"]);
      default:
        return ApiException(message ?? 'No internet connection', dio.options.headers["lang"]);
    }
  }

  /// Converts files   to multipart form data.
  Future<List<MapEntry<String, MultipartFile>>> convertFiles(
    List<Map<String, dynamic>> files,
  ) async {
    final List<MapEntry<String, MultipartFile>> entryList = [];

    for (final fileInfo in files) {
      final file = File(fileInfo['path']);
      if (await file.exists()) {
        final multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        );
        entryList.add(MapEntry(fileInfo['field_name'], multipartFile));
      }
    }

    return entryList;
  }

  /// Builds headers for requests.
  Map<String, String> _buildHeaders(String? token, String? version, {bool isMultipart = false}) {
    final headers = {
      'Accept': 'application/json',
      if (isMultipart) 'Content-Type': 'multipart/form-data',
      if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
      if ((version ?? '').isNotEmpty) 'version': '$version',
    };
    return headers;
  }

  /// Builds form data for multipart requests.
  Future<FormData> _buildFormData(dynamic data, List<Map<String, dynamic>>? files) async {
    final formData = data != null ? FormData.fromMap(data) : FormData();

    if (files != null && files.isNotEmpty) {
      final multipartFiles = await convertFiles(files);
      formData.files.addAll(multipartFiles);
    }

    return formData;
  }
}

class PrettyLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer();

    if (options.data != null && kDebugMode) {
      buffer.writeln("╔ Body Request");
      try {
        final body = jsonEncode(options.data);
        final formattedBody = _formatJson(body);

        // إضافة `║` في بداية كل سطر في `formattedBody`
        final indentedBody = formattedBody.split('\n').map((line) => '║ $line').join('\n');

        buffer.writeln(indentedBody);
      } catch (e) {
        buffer.writeln("║ ${options.data}");
      }
      buffer.writeln(
        "╚═══════════════════════════════════════════════════════════════════════════════════════════════╝",
      );
    }
    if (kDebugMode) {
      print(buffer.toString());
    }

    super.onRequest(options, handler);
  }

  // دالة تنسيق JSON
  String _formatJson(String jsonString) {
    final jsonObj = jsonDecode(jsonString);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObj);
  }
}
