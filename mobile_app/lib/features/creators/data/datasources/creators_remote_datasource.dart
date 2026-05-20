import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';
import '../models/country_model.dart';
import '../models/creator_model.dart';
import '../../domain/entities/creator_filters.dart';
import '../../domain/entities/creator_form_params.dart';

abstract class CreatorsRemoteDataSource {
  Future<List<CreatorModel>> getCreators(CreatorFilters filters);
  Future<CreatorModel> getCreatorById(String id);
  Future<List<CountryModel>> getCountries();
  Future<List<CategoryModel>> getCategories();
  Future<CreatorModel> createCreator(CreatorFormParams params);
  Future<CreatorModel> updateCreator(String id, CreatorFormParams params);
  Future<void> deleteCreator(String id);
}

class CreatorsRemoteDataSourceImpl implements CreatorsRemoteDataSource {
  final Dio _dio;

  CreatorsRemoteDataSourceImpl(DioClient client) : _dio = client.dio;

  @override
  Future<List<CreatorModel>> getCreators(CreatorFilters filters) async {
    final res = await _dio.get(
      '/creators',
      queryParameters: filters.toQueryParams(),
    );
    final list = res.data['creators'] as List<dynamic>;
    return list
        .map((e) => CreatorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CreatorModel> getCreatorById(String id) async {
    final res = await _dio.get('/creators/$id');
    return CreatorModel.fromJson(res.data['creator'] as Map<String, dynamic>);
  }

  @override
  Future<List<CountryModel>> getCountries() async {
    final res = await _dio.get('/countries');
    final list = res.data['countries'] as List<dynamic>;
    return list
        .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final res = await _dio.get('/categories');
    final list = res.data['categories'] as List<dynamic>;
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CreatorModel> createCreator(CreatorFormParams params) async {
    final res = await _dio.post('/creators', data: params.toJson());
    return CreatorModel.fromJson(res.data['creator'] as Map<String, dynamic>);
  }

  @override
  Future<CreatorModel> updateCreator(String id, CreatorFormParams params) async {
    final res = await _dio.put('/creators/$id', data: params.toJson());
    return CreatorModel.fromJson(res.data['creator'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCreator(String id) async {
    await _dio.delete('/creators/$id');
  }
}
