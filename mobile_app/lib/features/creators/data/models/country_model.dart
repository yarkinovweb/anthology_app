import '../../domain/entities/country_entity.dart';

class CountryModel extends CountryEntity {
  const CountryModel({
    required super.id,
    required super.name,
    required super.code,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id:   json['id']   as String,
        name: json['name'] as String,
        code: json['code'] as String,
      );
}
