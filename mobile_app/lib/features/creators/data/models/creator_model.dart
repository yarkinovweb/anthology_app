import '../../domain/entities/creator_entity.dart';
import 'work_preview_model.dart';

class CreatorModel extends CreatorEntity {
  const CreatorModel({
    required super.id,
    required super.name,
    super.bio,
    super.bornYear,
    super.diedYear,
    super.countryId,
    super.countryName,
    super.countryCode,
    super.categoryId,
    super.categoryName,
    super.works,
  });

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    final rawWorks = json['works'] as List<dynamic>?;
    return CreatorModel(
      id:           json['id']            as String,
      name:         json['name']          as String,
      bio:          json['bio']           as String?,
      bornYear:     (json['born_year']  as num?)?.toInt(),
      diedYear:     (json['died_year']  as num?)?.toInt(),
      countryId:    json['country_id']    as String?,
      countryName:  json['country_name']  as String?,
      countryCode:  json['country_code']  as String?,
      categoryId:   json['category_id']   as String?,
      categoryName: json['category_name'] as String?,
      works: rawWorks
              ?.map((w) => WorkPreviewModel.fromJson(w as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
