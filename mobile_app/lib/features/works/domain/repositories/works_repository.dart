import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/work_detail_entity.dart';

abstract class WorksRepository {
  Future<Either<Failure, WorkDetailEntity>> getWork(String id);
}
