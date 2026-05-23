import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remote;

  const SearchRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<CreatorEntity>>> searchCreators(
      String query) async {
    try {
      final result = await _remote.searchCreators(query);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkDetailEntity>>> searchWorks(
      String query) async {
    try {
      final result = await _remote.searchWorks(query);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('error_network');
    }
    final message =
        (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
            e.message ??
            'error_unknown';
    return ServerFailure(message);
  }
}
