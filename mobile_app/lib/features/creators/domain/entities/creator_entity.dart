import 'package:equatable/equatable.dart';
import 'work_preview_entity.dart';

class CreatorEntity extends Equatable {
  final String id;
  final String name;
  final String? bio;
  final int? bornYear;
  final int? diedYear;
  final String? countryId;
  final String? countryName;
  final String? countryCode;
  final String? categoryId;
  final String? categoryName;
  final List<WorkPreviewEntity> works;

  const CreatorEntity({
    required this.id,
    required this.name,
    this.bio,
    this.bornYear,
    this.diedYear,
    this.countryId,
    this.countryName,
    this.countryCode,
    this.categoryId,
    this.categoryName,
    this.works = const [],
  });

  String? get flagEmoji {
    if (countryCode == null) return null;
    return countryCode!.toUpperCase().split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) + 0x1F1A5);
    }).join();
  }

  String get lifespan {
    if (bornYear == null) return '';
    return diedYear != null ? '$bornYear – $diedYear' : '$bornYear –';
  }

  @override
  List<Object?> get props => [id, name, categoryId, countryId];
}
