part of 'video_player_bloc.dart';

abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();
  @override
  List<Object?> get props => [];
}

class VideoInitialState extends VideoPlayerState {
  const VideoInitialState();
}

class VideoLoadingState extends VideoPlayerState {
  const VideoLoadingState();
}

class VideoReadyState extends VideoPlayerState {
  final VideoPlayerController controller;
  const VideoReadyState({required this.controller});
  @override
  List<Object?> get props => [controller];
}

class VideoErrorState extends VideoPlayerState {
  final String message;
  const VideoErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
