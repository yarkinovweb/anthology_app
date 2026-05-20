import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/entities/creator_filters.dart';
import '../../domain/entities/creator_form_params.dart';
import '../../domain/repositories/creators_repository.dart';
import '../datasources/creators_remote_datasource.dart';

class CreatorsRepositoryImpl implements CreatorsRepository {
  final CreatorsRemoteDataSource _remote;

  const CreatorsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<CreatorEntity>>> getCreators(
      CreatorFilters filters) async {
    try {
      final result = await _remote.getCreators(filters);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreatorEntity>> getCreatorById(String id) async {
    try {
      final result = await _remote.getCreatorById(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() async {
    try {
      final result = await _remote.getCountries();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final result = await _remote.getCategories();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreatorEntity>> createCreator(CreatorFormParams params) async {
    try {
      final result = await _remote.createCreator(params);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreatorEntity>> updateCreator(String id, CreatorFormParams params) async {
    try {
      final result = await _remote.updateCreator(id, params);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCreator(String id) async {
    try {
      await _remote.deleteCreator(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('Internet aloqasi yo\'q');
    }
    final message =
        (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
            e.message ??
            'Xato yuz berdi';
    return ServerFailure(message);
  }
}
