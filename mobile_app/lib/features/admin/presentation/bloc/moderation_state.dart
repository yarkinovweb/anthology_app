part of 'moderation_bloc.dart';

abstract class ModerationState extends Equatable {
  const ModerationState();
  @override
  List<Object?> get props => [];
}

class ModerationInitialState extends ModerationState {
  const ModerationInitialState();
}

class ModerationLoadingState extends ModerationState {
  const ModerationLoadingState();
}

class ModerationLoadedState extends ModerationState {
  final List<PendingWorkEntity> works;
  final Set<String> processingIds;

  const ModerationLoadedState({
    required this.works,
    this.processingIds = const {},
  });

  ModerationLoadedState copyWith({
    List<PendingWorkEntity>? works,
    Set<String>? processingIds,
  }) =>
      ModerationLoadedState(
        works:         works         ?? this.works,
        processingIds: processingIds ?? this.processingIds,
      );

  @override
  List<Object?> get props => [works, processingIds];
}

class ModerationErrorState extends ModerationState {
  final String message;
  const ModerationErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
