import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../../works/domain/entities/work_detail_entity.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<CreatorEntity>>> searchCreators(String query);
  Future<Either<Failure, List<WorkDetailEntity>>> searchWorks(String query);
}
