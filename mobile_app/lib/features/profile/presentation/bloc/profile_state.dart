part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  final UserEntity user;
  const ProfileLoadedState(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileUpdatingState extends ProfileState {
  final UserEntity user;
  const ProfileUpdatingState(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileUpdateSuccessState extends ProfileState {
  final UserEntity user;
  const ProfileUpdateSuccessState(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileErrorState extends ProfileState {
  final String message;
  const ProfileErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
