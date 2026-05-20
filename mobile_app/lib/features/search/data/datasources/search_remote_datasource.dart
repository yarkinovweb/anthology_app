import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../creators/data/models/creator_model.dart';
import '../../../works/data/models/work_detail_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<CreatorModel>> searchCreators(String query);
  Future<List<WorkDetailModel>> searchWorks(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio _dio;

  SearchRemoteDataSourceImpl(DioClient client) : _dio = client.dio;

  @override
  Future<List<CreatorModel>> searchCreators(String query) async {
    final res = await _dio.get(
      '/creators',
      queryParameters: {'search': query},
    );
    final list = res.data['creators'] as List<dynamic>;
    return list
        .map((e) => CreatorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkDetailModel>> searchWorks(String query) async {
    final res = await _dio.get(
      '/works',
      queryParameters: {'search': query},
    );
    final list = res.data['works'] as List<dynamic>;
    return list
        .map((e) => WorkDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
