import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id:   json['id']   as String,
        name: json['name'] as String,
      );
}
