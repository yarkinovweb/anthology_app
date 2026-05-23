import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/pending_work_entity.dart';
import '../../domain/entities/upload_work_params.dart';
import '../../domain/entities/user_list_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remote;
  const AdminRepositoryImpl(this._remote);

  @override
  Stream<double> uploadWork(UploadWorkParams params) {
    return _remote.uploadWork(params).handleError((Object e) {
      if (e is DioException) throw _mapError(e);
      if (e is Failure) throw e;
      throw ServerFailure(e.toString());
    });
  }

  @override
  Future<Either<Failure, List<PendingWorkEntity>>> getPendingWorks() async {
    try {
      return Right(await _remote.getPendingWorks());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateWorkStatus(
      String id, String status) async {
    try {
      await _remote.updateWorkStatus(id, status);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats() async {
    try {
      return Right(await _remote.getDashboardStats());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserListEntity>>> getUsers() async {
    try {
      return Right(await _remote.getUsers());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserListEntity>> promoteUser(String userId) async {
    try {
      return Right(await _remote.promoteUser(userId));
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkDetailEntity>>> getAllWorks() async {
    try {
      return Right(await _remote.getAllWorks());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CreatorEntity>>> getAllCreators() async {
    try {
      return Right(await _remote.getAllCreators());
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
    if (code == 403) return const AuthFailure('error_auth');
    if (code == 404) return const ServerFailure('error_not_found');
    return ServerFailure(
        e.response?.data?['message'] as String? ?? 'error_server');
  }
}
