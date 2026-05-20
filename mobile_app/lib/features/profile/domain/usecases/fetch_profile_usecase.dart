import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class FetchProfileUseCase {
  final ProfileRepository _repository;
  const FetchProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() => _repository.getProfile();
}
