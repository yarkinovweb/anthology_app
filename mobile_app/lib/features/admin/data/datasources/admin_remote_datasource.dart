import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../creators/data/models/creator_model.dart';
import '../../../works/data/models/work_detail_model.dart';
import '../../domain/entities/upload_work_params.dart';
import '../models/dashboard_stats_model.dart';
import '../models/pending_work_model.dart';
import '../models/user_list_model.dart';

abstract class AdminRemoteDataSource {
  Stream<double> uploadWork(UploadWorkParams params);
  Future<List<PendingWorkModel>> getPendingWorks();
  Future<void> updateWorkStatus(String id, String status);
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<UserListModel>> getUsers();
  Future<UserListModel> promoteUser(String userId);
  Future<List<WorkDetailModel>> getAllWorks();
  Future<List<CreatorModel>> getAllCreators();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio _dio;
  AdminRemoteDataSourceImpl(DioClient client) : _dio = client.dio;

  @override
  Stream<double> uploadWork(UploadWorkParams params) {
    final controller = StreamController<double>();
    _executeUpload(params, controller);
    return controller.stream;
  }

  Future<void> _executeUpload(
      UploadWorkParams params, StreamController<double> controller) async {
    try {
      final fields = <String, dynamic>{
        'creator_id': params.creatorId,
        'title':      params.title,
      };
      if (params.description?.isNotEmpty == true) {
        fields['description'] = params.description;
      }
      if (params.contentText?.isNotEmpty == true) {
        fields['content_text'] = params.contentText;
      }
      if (params.hasFile) {
        fields['file'] = await MultipartFile.fromFile(
          params.filePath!,
          filename: params.fileName ?? 'upload',
        );
      }

      await _dio.post(
        '/works/upload',
        data: FormData.fromMap(fields),
        onSendProgress: (sent, total) {
          if (total > 0 && !controller.isClosed) {
            controller.add((sent / total).clamp(0.0, 1.0));
          }
        },
      );

      if (!controller.isClosed) controller.close();
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
        controller.close();
      }
    }
  }

  @override
  Future<List<PendingWorkModel>> getPendingWorks() async {
    final res = await _dio.get(
      '/works',
      queryParameters: {'status': 'pending'},
    );
    final list = res.data['works'] as List<dynamic>;
    return list
        .map((e) => PendingWorkModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateWorkStatus(String id, String status) async {
    await _dio.patch('/works/$id/status', data: {'status': status});
  }

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    final res = await _dio.get('/admin/dashboard-stats');
    return DashboardStatsModel.fromJson(
        res.data['stats'] as Map<String, dynamic>);
  }

  @override
  Future<List<UserListModel>> getUsers() async {
    final res = await _dio.get('/admin/users');
    final list = res.data['users'] as List<dynamic>;
    return list
        .map((e) => UserListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserListModel> promoteUser(String userId) async {
    final res = await _dio.patch('/admin/users/$userId/promote');
    return UserListModel.fromJson(res.data['user'] as Map<String, dynamic>);
  }

  @override
  Future<List<WorkDetailModel>> getAllWorks() async {
    final res = await _dio.get('/works', queryParameters: {'status': 'all'});
    final list = res.data['works'] as List<dynamic>;
    return list
        .map((e) => WorkDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CreatorModel>> getAllCreators() async {
    final res = await _dio.get('/creators');
    final list = res.data['creators'] as List<dynamic>;
    return list
        .map((e) => CreatorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
