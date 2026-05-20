part of 'video_player_bloc.dart';

abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();
  @override
  List<Object?> get props => [];
}

class VideoLoadEvent extends VideoPlayerEvent {
  final String url;
  const VideoLoadEvent(this.url);
  @override
  List<Object?> get props => [url];
}

class VideoPlayEvent extends VideoPlayerEvent {
  const VideoPlayEvent();
}

class VideoPauseEvent extends VideoPlayerEvent {
  const VideoPauseEvent();
}

class VideoSeekEvent extends VideoPlayerEvent {
  final Duration position;
  const VideoSeekEvent(this.position);
  @override
  List<Object?> get props => [position];
}

class VideoDisposeEvent extends VideoPlayerEvent {
  const VideoDisposeEvent();
}
