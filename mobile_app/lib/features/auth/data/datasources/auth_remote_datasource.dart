import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

typedef AuthResult = (UserModel user, String accessToken, String refreshToken);

abstract class AuthRemoteDataSource {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(String name, String email, String password, String role);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(DioClient client) : _dio = client.dio;

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email':    email,
        'password': password,
      });
      return _parseResponse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<AuthResult> register(String name, String email, String password, String role) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'name':     name,
        'email':    email,
        'password': password,
        'role':     role,
      });
      return _parseResponse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AuthResult _parseResponse(Map<String, dynamic> data) {
    final user         = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final accessToken  = data['access_token']  as String;
    final refreshToken = data['refresh_token'] as String;
    return (user, accessToken, refreshToken);
  }

  Exception _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    final message = _extractMessage(e);
    if (e.response?.statusCode == 401 || e.response?.statusCode == 409) {
      return AuthException(message);
    }
    return ServerException(message);
  }

  String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'error_unknown';
      }
      if (data is String && data.isNotEmpty) return data;
    } catch (_) {}
    return e.message ?? 'error_unknown';
  }
}
