part of 'creator_detail_bloc.dart';

abstract class CreatorDetailState extends Equatable {
  const CreatorDetailState();
  @override List<Object?> get props => [];
}

class CreatorDetailInitial extends CreatorDetailState {
  const CreatorDetailInitial();
}

class CreatorDetailLoading extends CreatorDetailState {
  const CreatorDetailLoading();
}

class CreatorDetailLoaded extends CreatorDetailState {
  final CreatorEntity creator;
  const CreatorDetailLoaded(this.creator);

  @override List<Object?> get props => [creator];
}

class CreatorDetailError extends CreatorDetailState {
  final String message;
  const CreatorDetailError(this.message);

  @override List<Object?> get props => [message];
}
