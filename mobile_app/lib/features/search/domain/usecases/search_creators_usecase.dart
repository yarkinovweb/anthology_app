import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../repositories/search_repository.dart';

class SearchCreatorsUseCase {
  final SearchRepository _repository;
  const SearchCreatorsUseCase(this._repository);

  Future<Either<Failure, List<CreatorEntity>>> call(String query) =>
      _repository.searchCreators(query);
}
