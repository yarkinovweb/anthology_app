import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../entities/country_entity.dart';
import '../entities/creator_entity.dart';
import '../entities/creator_filters.dart';
import '../entities/creator_form_params.dart';

abstract class CreatorsRepository {
  Future<Either<Failure, List<CreatorEntity>>> getCreators(CreatorFilters filters);
  Future<Either<Failure, CreatorEntity>> getCreatorById(String id);
  Future<Either<Failure, List<CountryEntity>>> getCountries();
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, CreatorEntity>> createCreator(CreatorFormParams params);
  Future<Either<Failure, CreatorEntity>> updateCreator(String id, CreatorFormParams params);
  Future<Either<Failure, void>> deleteCreator(String id);
}
