part of 'audio_player_bloc.dart';

abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();
  @override
  List<Object?> get props => [];
}

class AudioInitialState extends AudioPlayerState {
  const AudioInitialState();
}

class AudioLoadingState extends AudioPlayerState {
  const AudioLoadingState();
}

class AudioPlayingState extends AudioPlayerState {
  final Duration position;
  final Duration duration;
  const AudioPlayingState({required this.position, required this.duration});
  @override
  List<Object?> get props => [position, duration];
}

class AudioPausedState extends AudioPlayerState {
  final Duration position;
  final Duration duration;
  const AudioPausedState({required this.position, required this.duration});
  @override
  List<Object?> get props => [position, duration];
}

class AudioStoppedState extends AudioPlayerState {
  const AudioStoppedState();
}

class AudioErrorState extends AudioPlayerState {
  final String message;
  const AudioErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
