part of 'moderation_bloc.dart';

abstract class ModerationEvent extends Equatable {
  const ModerationEvent();
  @override
  List<Object?> get props => [];
}

class FetchPendingWorksEvent extends ModerationEvent {
  const FetchPendingWorksEvent();
}

class ApproveWorkEvent extends ModerationEvent {
  final String id;
  const ApproveWorkEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class RejectWorkEvent extends ModerationEvent {
  final String id;
  const RejectWorkEvent(this.id);
  @override
  List<Object?> get props => [id];
}
