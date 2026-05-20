import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/creator_entity.dart';
import '../repositories/creators_repository.dart';

class GetCreatorDetailUseCase {
  final CreatorsRepository _repository;
  const GetCreatorDetailUseCase(this._repository);

  Future<Either<Failure, CreatorEntity>> call(String id) =>
      _repository.getCreatorById(id);
}
