import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/update_profile_params.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  const ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      return Right(await _remote.getProfile());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
      UpdateProfileParams params) async {
    try {
      return Right(await _remote.updateProfile(params));
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
    return ServerFailure(
        e.response?.data?['message'] as String? ?? 'error_server');
  }
}
