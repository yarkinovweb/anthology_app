part of 'creator_detail_bloc.dart';

abstract class CreatorDetailEvent extends Equatable {
  const CreatorDetailEvent();
  @override List<Object?> get props => [];
}

class LoadCreatorDetailEvent extends CreatorDetailEvent {
  final String creatorId;
  const LoadCreatorDetailEvent(this.creatorId);

  @override List<Object?> get props => [creatorId];
}
