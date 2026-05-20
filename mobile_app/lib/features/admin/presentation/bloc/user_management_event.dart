part of 'user_management_bloc.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();
  @override
  List<Object?> get props => [];
}

class FetchUsersEvent extends UserManagementEvent {
  const FetchUsersEvent();
}

class PromoteUserEvent extends UserManagementEvent {
  final String userId;
  const PromoteUserEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}
