import '../../domain/entities/work_preview_entity.dart';

class WorkPreviewModel extends WorkPreviewEntity {
  const WorkPreviewModel({
    required super.id,
    required super.title,
    super.description,
    required super.mediaUrl,
    required super.mediaType,
    required super.fileSize,
    super.contentText,
    required super.createdAt,
  });

  factory WorkPreviewModel.fromJson(Map<String, dynamic> json) =>
      WorkPreviewModel(
        id:          json['id']          as String,
        title:       json['title']       as String,
        description: json['description'] as String?,
        mediaUrl:    json['media_url']   as String,
        mediaType:   json['media_type']  as String,
        fileSize:    int.tryParse(json['file_size'].toString()) ?? 0,
        contentText: json['content_text'] as String?,
        createdAt:   json['created_at']  as String,
      );
}
