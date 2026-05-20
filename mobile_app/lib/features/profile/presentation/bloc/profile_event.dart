part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {
  const FetchProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final String? password;
  const UpdateProfileEvent({this.name, this.password});
  @override
  List<Object?> get props => [name, password];
}
