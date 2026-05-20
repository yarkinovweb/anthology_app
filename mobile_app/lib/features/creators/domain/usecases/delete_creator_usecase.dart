import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/creators_repository.dart';

class DeleteCreatorUseCase {
  final CreatorsRepository _repository;

  const DeleteCreatorUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteCreator(id);
}
