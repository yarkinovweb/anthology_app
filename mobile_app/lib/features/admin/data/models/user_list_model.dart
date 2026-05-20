import '../../domain/entities/user_list_entity.dart';

class UserListModel extends UserListEntity {
  const UserListModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) => UserListModel(
        id:    json['id']    as String,
        name:  json['name']  as String,
        email: json['email'] as String,
        role:  json['role']  as String,
      );
}
