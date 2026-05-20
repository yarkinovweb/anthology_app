import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_list_entity.dart';
import '../repositories/admin_repository.dart';

class GetUsersUseCase {
  final AdminRepository _repository;
  const GetUsersUseCase(this._repository);

  Future<Either<Failure, List<UserListEntity>>> call() =>
      _repository.getUsers();
}
