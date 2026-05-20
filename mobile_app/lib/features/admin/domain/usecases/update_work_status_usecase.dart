import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

class UpdateWorkStatusParams {
  final String id;
  final String status; // 'approved' | 'rejected'
  const UpdateWorkStatusParams({required this.id, required this.status});
}

class UpdateWorkStatusUseCase {
  final AdminRepository _repository;
  const UpdateWorkStatusUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UpdateWorkStatusParams params) =>
      _repository.updateWorkStatus(params.id, params.status);
}
