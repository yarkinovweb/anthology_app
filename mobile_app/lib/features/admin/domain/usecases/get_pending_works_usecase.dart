import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pending_work_entity.dart';
import '../repositories/admin_repository.dart';

class GetPendingWorksUseCase {
  final AdminRepository _repository;
  const GetPendingWorksUseCase(this._repository);

  Future<Either<Failure, List<PendingWorkEntity>>> call() =>
      _repository.getPendingWorks();
}
