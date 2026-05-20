import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerController? _controller;

  VideoPlayerBloc() : super(const VideoInitialState()) {
    on<VideoLoadEvent>(_onLoad);
    on<VideoPlayEvent>(_onPlay);
    on<VideoPauseEvent>(_onPause);
    on<VideoSeekEvent>(_onSeek);
    on<VideoDisposeEvent>(_onDispose);
  }

  Future<void> _onLoad(
      VideoLoadEvent event, Emitter<VideoPlayerState> emit) async {
    emit(const VideoLoadingState());
    await _disposeController();

    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(event.url));
      await _controller!.initialize();
      emit(VideoReadyState(controller: _controller!));
    } catch (e) {
      emit(VideoErrorState(e.toString()));
    }
  }

  void _onPlay(VideoPlayEvent event, Emitter<VideoPlayerState> emit) {
    _controller?.play();
  }

  void _onPause(VideoPauseEvent event, Emitter<VideoPlayerState> emit) {
    _controller?.pause();
  }

  void _onSeek(VideoSeekEvent event, Emitter<VideoPlayerState> emit) {
    _controller?.seekTo(event.position);
  }

  Future<void> _onDispose(
      VideoDisposeEvent event, Emitter<VideoPlayerState> emit) async {
    await _disposeController();
    emit(const VideoInitialState());
  }

  Future<void> _disposeController() async {
    await _controller?.dispose();
    _controller = null;
  }

  @override
  Future<void> close() async {
    await _disposeController();
    return super.close();
  }
}
