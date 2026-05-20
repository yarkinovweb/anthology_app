import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../repositories/search_repository.dart';

class SearchWorksUseCase {
  final SearchRepository _repository;
  const SearchWorksUseCase(this._repository);

  Future<Either<Failure, List<WorkDetailEntity>>> call(String query) =>
      _repository.searchWorks(query);
}
