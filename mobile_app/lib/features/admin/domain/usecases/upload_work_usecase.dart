import '../entities/upload_work_params.dart';
import '../repositories/admin_repository.dart';

class UploadWorkUseCase {
  final AdminRepository _repository;
  const UploadWorkUseCase(this._repository);

  Stream<double> call(UploadWorkParams params) =>
      _repository.uploadWork(params);
}
