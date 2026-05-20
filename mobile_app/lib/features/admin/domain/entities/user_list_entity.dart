import 'package:equatable/equatable.dart';

class UserListEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserListEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isPromotable => role == 'user' || role == 'researcher';

  @override
  List<Object?> get props => [id, name, email, role];
}
