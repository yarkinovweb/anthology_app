import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminCreatorsUseCase {
  final AdminRepository _repository;
  const GetAdminCreatorsUseCase(this._repository);

  Future<Either<Failure, List<CreatorEntity>>> call() =>
      _repository.getAllCreators();
}
