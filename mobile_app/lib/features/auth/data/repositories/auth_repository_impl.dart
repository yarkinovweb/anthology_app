import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final HiveStorage _storage;

  const AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final (user, access, refresh) = await _remote.login(email, password);
      await _saveSession(user, access, refresh);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('error_network'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
      String name, String email, String password, String role) async {
    try {
      final (user, access, refresh) =
          await _remote.register(name, email, password, role);
      await _saveSession(user, access, refresh);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('error_network'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getLocalUser() async {
    try {
      final token = _storage.getAccessToken();
      if (token == null) return const Right(null);

      final userData = _storage.getUser();
      if (userData == null) return const Right(null);

      return Right(UserModel.fromJson(userData));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _storage.clearAuth();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> _saveSession(UserModel user, String access, String refresh) async {
    await _storage.saveTokens(accessToken: access, refreshToken: refresh);
    await _storage.saveUser(user.toJson());
  }
}
