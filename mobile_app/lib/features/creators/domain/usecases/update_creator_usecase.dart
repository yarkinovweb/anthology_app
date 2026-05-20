import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/creator_entity.dart';
import '../entities/creator_form_params.dart';
import '../repositories/creators_repository.dart';

class UpdateCreatorUseCase {
  final CreatorsRepository _repository;

  const UpdateCreatorUseCase(this._repository);

  Future<Either<Failure, CreatorEntity>> call(String id, CreatorFormParams params) =>
      _repository.updateCreator(id, params);
}
