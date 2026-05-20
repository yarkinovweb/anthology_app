import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_stats_entity.dart';
import '../repositories/admin_repository.dart';

class GetDashboardStatsUseCase {
  final AdminRepository _repository;
  const GetDashboardStatsUseCase(this._repository);

  Future<Either<Failure, DashboardStatsEntity>> call() =>
      _repository.getDashboardStats();
}
