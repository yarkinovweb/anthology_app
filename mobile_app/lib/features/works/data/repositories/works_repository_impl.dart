import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/work_detail_entity.dart';
import '../../domain/repositories/works_repository.dart';
import '../datasources/works_remote_datasource.dart';

class WorksRepositoryImpl implements WorksRepository {
  final WorksRemoteDataSource _remote;
  const WorksRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, WorkDetailEntity>> getWork(String id) async {
    try {
      return Right(await _remote.getWork(id));
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure('error_network');
    }
    final code = e.response?.statusCode;
    if (code == 401) return const AuthFailure('error_auth');
    if (code == 404) return const ServerFailure('error_not_found');
    return ServerFailure(
        e.response?.data?['message'] as String? ?? 'error_server');
  }
}
