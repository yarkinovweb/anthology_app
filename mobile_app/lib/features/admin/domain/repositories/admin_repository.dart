import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../entities/dashboard_stats_entity.dart';
import '../entities/pending_work_entity.dart';
import '../entities/upload_work_params.dart';
import '../entities/user_list_entity.dart';

abstract class AdminRepository {
  /// Emits upload progress 0.0–1.0; throws [Failure] on error.
  Stream<double> uploadWork(UploadWorkParams params);

  Future<Either<Failure, List<PendingWorkEntity>>> getPendingWorks();

  Future<Either<Failure, Unit>> updateWorkStatus(String id, String status);

  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats();

  Future<Either<Failure, List<UserListEntity>>> getUsers();

  Future<Either<Failure, UserListEntity>> promoteUser(String userId);

  Future<Either<Failure, List<WorkDetailEntity>>> getAllWorks();

  Future<Either<Failure, List<CreatorEntity>>> getAllCreators();
}
