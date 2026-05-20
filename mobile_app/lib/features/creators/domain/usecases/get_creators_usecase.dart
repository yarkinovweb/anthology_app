import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/creator_entity.dart';
import '../entities/creator_filters.dart';
import '../repositories/creators_repository.dart';

class GetCreatorsUseCase {
  final CreatorsRepository _repository;
  const GetCreatorsUseCase(this._repository);

  Future<Either<Failure, List<CreatorEntity>>> call(CreatorFilters filters) =>
      _repository.getCreators(filters);
}
