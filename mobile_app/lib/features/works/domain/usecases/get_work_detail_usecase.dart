import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/work_detail_entity.dart';
import '../repositories/works_repository.dart';

class GetWorkDetailUseCase {
  final WorksRepository _repository;
  const GetWorkDetailUseCase(this._repository);

  Future<Either<Failure, WorkDetailEntity>> call(String id) =>
      _repository.getWork(id);
}
