import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/hive_storage.dart';

class TokenInterceptor extends QueuedInterceptorsWrapper {
  final HiveStorage _storage;

  // Interceptorsiz alohida Dio — token yangilash va retry uchun
  final Dio _plainDio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
    ),
  );

  TokenInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // Foydalanuvchi tanlagan tilni backend tarjima uchun yuboradi
    final lang = _storage.getLanguage() ?? 'uz';
    options.headers['Accept-Language'] = lang;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = _storage.getRefreshToken();
    if (refreshToken == null) {
      await _storage.clearAuth();
      return handler.next(err);
    }

    try {
      final refreshResp = await _plainDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccess  = refreshResp.data['access_token']  as String;
      final newRefresh = refreshResp.data['refresh_token'] as String;

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Asl so'rovni yangi token bilan qayta yuborish
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retried = await _plainDio.fetch(err.requestOptions);
      return handler.resolve(retried);
    } on DioException {
      // Refresh ham ishlamasa — tokenlarni tozala (login ekraniga o'tish UI da hal qilinadi)
      await _storage.clearAuth();
      return handler.next(err);
    }
  }
}
