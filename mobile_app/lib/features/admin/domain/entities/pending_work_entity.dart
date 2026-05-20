import 'package:equatable/equatable.dart';

class PendingWorkEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String mediaType;
  final String? creatorId;
  final String? creatorName;
  final String createdAt;

  const PendingWorkEntity({
    required this.id,
    required this.title,
    this.description,
    required this.mediaType,
    this.creatorId,
    this.creatorName,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, title, description, mediaType, creatorId, creatorName, createdAt];
}
