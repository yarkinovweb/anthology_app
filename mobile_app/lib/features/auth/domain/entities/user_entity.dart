import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin      => role == 'admin';
  bool get isSpecialist => role == 'specialist';
  bool get isResearcher => role == 'researcher';
  bool get canModerate  => isSpecialist;
  bool get canUpload    => isResearcher || isSpecialist;
  bool get canManageCreators => isSpecialist;

  @override
  List<Object?> get props => [id, name, email, role];
}
