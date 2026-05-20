import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_list_entity.dart';
import '../repositories/admin_repository.dart';

class PromoteUserUseCase {
  final AdminRepository _repository;
  const PromoteUserUseCase(this._repository);

  Future<Either<Failure, UserListEntity>> call(String userId) =>
      _repository.promoteUser(userId);
}
