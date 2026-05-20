import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/creator_entity.dart';
import '../entities/creator_form_params.dart';
import '../repositories/creators_repository.dart';

class CreateCreatorUseCase {
  final CreatorsRepository _repository;

  const CreateCreatorUseCase(this._repository);

  Future<Either<Failure, CreatorEntity>> call(CreatorFormParams params) =>
      _repository.createCreator(params);
}
