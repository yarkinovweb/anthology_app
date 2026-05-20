import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/hive_storage.dart';
import 'token_interceptor.dart';

class DioClient {
  late final Dio _dio;

  DioClient(HiveStorage storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(TokenInterceptor(storage));
  }

  Dio get dio => _dio;
}
