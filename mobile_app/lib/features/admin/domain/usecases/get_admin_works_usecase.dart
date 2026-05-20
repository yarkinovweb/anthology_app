import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminWorksUseCase {
  final AdminRepository _repository;
  const GetAdminWorksUseCase(this._repository);

  Future<Either<Failure, List<WorkDetailEntity>>> call() =>
      _repository.getAllWorks();
}
