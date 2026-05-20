import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/country_entity.dart';
import '../repositories/creators_repository.dart';

class GetCountriesUseCase {
  final CreatorsRepository _repository;
  const GetCountriesUseCase(this._repository);

  Future<Either<Failure, List<CountryEntity>>> call() =>
      _repository.getCountries();
}
