import '../../domain/entities/work_detail_entity.dart';

class WorkDetailModel extends WorkDetailEntity {
  const WorkDetailModel({
    required super.id,
    required super.title,
    super.description,
    super.mediaUrl,
    required super.mediaType,
    super.fileSize,
    super.contentText,
    super.status,
    required super.createdAt,
    super.creatorId,
    super.creatorName,
  });

  factory WorkDetailModel.fromJson(Map<String, dynamic> json) {
    return WorkDetailModel(
      id:          json['id'] as String,
      title:       json['title'] as String,
      description: json['description'] as String?,
      mediaUrl:    json['media_url'] as String?,
      mediaType:   json['media_type'] as String? ?? 'pdf',
      fileSize:    json['file_size'] != null ? int.tryParse(json['file_size'].toString()) : null,
      contentText: json['content_text'] as String?,
      status:      json['status'] as String?,
      createdAt:   json['created_at'] as String? ?? '',
      creatorId:   json['creator_id'] as String?,
      creatorName: json['creator_name'] as String?,
    );
  }
}
