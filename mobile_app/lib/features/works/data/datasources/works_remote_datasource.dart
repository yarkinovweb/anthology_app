import '../../../../core/network/dio_client.dart';
import '../models/work_detail_model.dart';

abstract class WorksRemoteDataSource {
  Future<WorkDetailModel> getWork(String id);
}

class WorksRemoteDataSourceImpl implements WorksRemoteDataSource {
  final DioClient _dio;
  const WorksRemoteDataSourceImpl(this._dio);

  @override
  Future<WorkDetailModel> getWork(String id) async {
    final response = await _dio.dio.get('/works/$id');
    return WorkDetailModel.fromJson(
        response.data['work'] as Map<String, dynamic>);
  }
}
