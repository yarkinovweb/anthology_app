part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();
  @override
  List<Object?> get props => [];
}

class AudioLoadEvent extends AudioPlayerEvent {
  final String url;
  const AudioLoadEvent(this.url);
  @override
  List<Object?> get props => [url];
}

class AudioPlayEvent extends AudioPlayerEvent {
  const AudioPlayEvent();
}

class AudioPauseEvent extends AudioPlayerEvent {
  const AudioPauseEvent();
}

class AudioSeekEvent extends AudioPlayerEvent {
  final Duration position;
  const AudioSeekEvent(this.position);
  @override
  List<Object?> get props => [position];
}

class AudioStopEvent extends AudioPlayerEvent {
  const AudioStopEvent();
}

// Internal events — library-private, used only by the bloc
class _AudioPositionChangedEvent extends AudioPlayerEvent {
  final Duration position;
  const _AudioPositionChangedEvent(this.position);
  @override
  List<Object?> get props => [position];
}

class _AudioDurationChangedEvent extends AudioPlayerEvent {
  final Duration duration;
  const _AudioDurationChangedEvent(this.duration);
  @override
  List<Object?> get props => [duration];
}

class _AudioCompletedEvent extends AudioPlayerEvent {
  const _AudioCompletedEvent();
}

class _AudioErrorEvent extends AudioPlayerEvent {
  final String message;
  const _AudioErrorEvent(this.message);
  @override
  List<Object?> get props => [message];
}
