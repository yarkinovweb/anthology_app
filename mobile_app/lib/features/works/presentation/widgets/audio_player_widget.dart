import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/audio_player_bloc.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final String title;
  const AudioPlayerWidget({super.key, required this.url, required this.title});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AudioPlayerBloc>();
    _bloc.add(AudioLoadEvent(widget.url));
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final isLoading = state is AudioLoadingState;
        final isPlaying = state is AudioPlayingState;

        Duration position = Duration.zero;
        Duration duration = Duration.zero;
        if (state is AudioPlayingState) {
          position = state.position;
          duration = state.duration;
        } else if (state is AudioPausedState) {
          position = state.position;
          duration = state.duration;
        }

        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.music_note, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              if (state is AudioErrorState)
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                )
              else ...[
                SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 3,
                    thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor:   Colors.white,
                    inactiveTrackColor: Colors.white30,
                    thumbColor:         Colors.white,
                    overlayColor:       Colors.white24,
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: duration.inMilliseconds > 0
                        ? (v) => _bloc.add(AudioSeekEvent(Duration(
                              milliseconds:
                                  (v * duration.inMilliseconds).round(),
                            )))
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(position),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      Text(_fmt(duration),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10,
                          color: Colors.white, size: 32),
                      onPressed: () => _bloc.add(AudioSeekEvent(
                          position - const Duration(seconds: 10))),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppTheme.primary,
                                size: 32,
                              ),
                              onPressed: () {
                                if (isPlaying) {
                                  _bloc.add(const AudioPauseEvent());
                                } else {
                                  _bloc.add(const AudioPlayEvent());
                                }
                              },
                            ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.forward_10,
                          color: Colors.white, size: 32),
                      onPressed: () => _bloc.add(AudioSeekEvent(
                          position + const Duration(seconds: 10))),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
