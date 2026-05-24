import 'package:equatable/equatable.dart';

class WorkPreviewEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? mediaUrl;
  final String mediaType;
  final int fileSize;
  final String? contentText;
  final String createdAt;

  const WorkPreviewEntity({
    required this.id,
    required this.title,
    this.description,
    this.mediaUrl,
    required this.mediaType,
    required this.fileSize,
    this.contentText,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, mediaType];
}
