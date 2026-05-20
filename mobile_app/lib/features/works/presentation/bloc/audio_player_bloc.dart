import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<void>?     _completeSub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  AudioPlayerBloc() : super(const AudioInitialState()) {
    on<AudioLoadEvent>(_onLoad);
    on<AudioPlayEvent>(_onPlay);
    on<AudioPauseEvent>(_onPause);
    on<AudioSeekEvent>(_onSeek);
    on<AudioStopEvent>(_onStop);
    on<_AudioPositionChangedEvent>(_onPositionChanged);
    on<_AudioDurationChangedEvent>(_onDurationChanged);
    on<_AudioCompletedEvent>(_onCompleted);
    on<_AudioErrorEvent>(_onAudioError);
  }

  Future<void> _onLoad(
      AudioLoadEvent event, Emitter<AudioPlayerState> emit) async {
    emit(const AudioLoadingState());
    _position = Duration.zero;
    _duration = Duration.zero;

    await _cancelSubscriptions();

    _positionSub = _player.onPositionChanged
        .listen((pos) => add(_AudioPositionChangedEvent(pos)));
    _durationSub = _player.onDurationChanged
        .listen((dur) => add(_AudioDurationChangedEvent(dur)));
    _completeSub =
        _player.onPlayerComplete.listen((_) => add(const _AudioCompletedEvent()));

    try {
      await _player.play(UrlSource(event.url));
    } catch (e) {
      add(_AudioErrorEvent(e.toString()));
    }
  }

  void _onPlay(AudioPlayEvent event, Emitter<AudioPlayerState> emit) {
    _player.resume();
    emit(AudioPlayingState(position: _position, duration: _duration));
  }

  void _onPause(AudioPauseEvent event, Emitter<AudioPlayerState> emit) {
    _player.pause();
    emit(AudioPausedState(position: _position, duration: _duration));
  }

  void _onSeek(AudioSeekEvent event, Emitter<AudioPlayerState> emit) {
    final clamped = _clamp(event.position);
    _player.seek(clamped);
    _position = clamped;
    final s = state;
    if (s is AudioPlayingState) {
      emit(AudioPlayingState(position: _position, duration: _duration));
    } else if (s is AudioPausedState) {
      emit(AudioPausedState(position: _position, duration: _duration));
    }
  }

  Future<void> _onStop(
      AudioStopEvent event, Emitter<AudioPlayerState> emit) async {
    await _player.stop();
    _position = Duration.zero;
    emit(const AudioStoppedState());
  }

  void _onPositionChanged(
      _AudioPositionChangedEvent event, Emitter<AudioPlayerState> emit) {
    _position = event.position;
    final s = state;
    if (s is AudioPlayingState || s is AudioLoadingState) {
      emit(AudioPlayingState(position: _position, duration: _duration));
    } else if (s is AudioPausedState) {
      emit(AudioPausedState(position: _position, duration: _duration));
    }
  }

  void _onDurationChanged(
      _AudioDurationChangedEvent event, Emitter<AudioPlayerState> emit) {
    _duration = event.duration;
    final s = state;
    if (s is AudioPlayingState || s is AudioLoadingState) {
      emit(AudioPlayingState(position: _position, duration: _duration));
    } else if (s is AudioPausedState) {
      emit(AudioPausedState(position: _position, duration: _duration));
    }
  }

  void _onCompleted(
      _AudioCompletedEvent event, Emitter<AudioPlayerState> emit) {
    _position = Duration.zero;
    emit(AudioPausedState(position: Duration.zero, duration: _duration));
  }

  void _onAudioError(
      _AudioErrorEvent event, Emitter<AudioPlayerState> emit) {
    emit(AudioErrorState(event.message));
  }

  Duration _clamp(Duration pos) {
    if (pos < Duration.zero) return Duration.zero;
    if (_duration > Duration.zero && pos > _duration) return _duration;
    return pos;
  }

  Future<void> _cancelSubscriptions() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _completeSub?.cancel();
    _positionSub = null;
    _durationSub = null;
    _completeSub = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    await _player.dispose();
    return super.close();
  }
}
