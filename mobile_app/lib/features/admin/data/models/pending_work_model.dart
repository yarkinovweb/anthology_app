import '../../domain/entities/pending_work_entity.dart';

class PendingWorkModel extends PendingWorkEntity {
  const PendingWorkModel({
    required super.id,
    required super.title,
    super.description,
    required super.mediaType,
    super.creatorId,
    super.creatorName,
    required super.createdAt,
  });

  factory PendingWorkModel.fromJson(Map<String, dynamic> json) {
    return PendingWorkModel(
      id:          json['id'] as String,
      title:       json['title'] as String,
      description: json['description'] as String?,
      mediaType:   json['media_type'] as String? ?? 'pdf',
      creatorId:   json['creator_id'] as String?,
      creatorName: json['creator_name'] as String?,
      createdAt:   json['created_at'] as String? ?? '',
    );
  }
}
