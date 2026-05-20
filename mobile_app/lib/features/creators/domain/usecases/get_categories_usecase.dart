import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/creators_repository.dart';

class GetCategoriesUseCase {
  final CreatorsRepository _repository;
  const GetCategoriesUseCase(this._repository);

  Future<Either<Failure, List<CategoryEntity>>> call() =>
      _repository.getCategories();
}
