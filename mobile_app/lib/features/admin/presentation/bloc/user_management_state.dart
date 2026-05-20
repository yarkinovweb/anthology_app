part of 'user_management_bloc.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();
  @override
  List<Object?> get props => [];
}

class UserManagementInitialState extends UserManagementState {
  const UserManagementInitialState();
}

class UserManagementLoadingState extends UserManagementState {
  const UserManagementLoadingState();
}

class UserManagementLoadedState extends UserManagementState {
  final List<UserListEntity> users;
  final Set<String> promotingIds;

  const UserManagementLoadedState({
    required this.users,
    this.promotingIds = const {},
  });

  UserManagementLoadedState copyWith({
    List<UserListEntity>? users,
    Set<String>? promotingIds,
  }) =>
      UserManagementLoadedState(
        users:        users        ?? this.users,
        promotingIds: promotingIds ?? this.promotingIds,
      );

  @override
  List<Object?> get props => [users, promotingIds];
}

class UserManagementErrorState extends UserManagementState {
  final String message;
  const UserManagementErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
