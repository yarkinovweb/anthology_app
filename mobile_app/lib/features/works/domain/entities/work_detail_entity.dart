import 'package:equatable/equatable.dart';

class WorkDetailEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? mediaUrl;
  final String mediaType;
  final int? fileSize;
  final String? contentText;
  final String? status;
  final String createdAt;
  final String? creatorId;
  final String? creatorName;

  const WorkDetailEntity({
    required this.id,
    required this.title,
    this.description,
    this.mediaUrl,
    required this.mediaType,
    this.fileSize,
    this.contentText,
    this.status,
    required this.createdAt,
    this.creatorId,
    this.creatorName,
  });

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  bool get hasText  => contentText != null && contentText!.isNotEmpty;
  bool get isVideo  => mediaType == 'video';
  bool get isAudio  => mediaType == 'audio';
  bool get isImage  => mediaType == 'image';
  bool get isPdf    => mediaType == 'pdf';

  @override
  List<Object?> get props => [
        id, title, description, mediaUrl, mediaType,
        fileSize, contentText, status, createdAt,
        creatorId, creatorName,
      ];
}
