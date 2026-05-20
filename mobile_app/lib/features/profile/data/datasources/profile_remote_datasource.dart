import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/update_profile_params.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateProfileParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
  ProfileRemoteDataSourceImpl(DioClient client) : _dio = client.dio;

  @override
  Future<UserModel> getProfile() async {
    final res = await _dio.get('/users/profile');
    return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileParams params) async {
    final data = <String, dynamic>{};
    if (params.name != null)     data['name']     = params.name;
    if (params.password != null) data['password'] = params.password;
    final res = await _dio.put('/users/profile/update', data: data);
    return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
  }
}
