import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/video_player_bloc.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final VideoPlayerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<VideoPlayerBloc>();
    _bloc.add(VideoLoadEvent(widget.url));
  }

  @override
  void dispose() {
    _bloc.add(const VideoDisposeEvent());
    super.dispose();
  }

  String _fmt(Duration d) {
    final h  = d.inHours;
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        if (state is VideoInitialState || state is VideoLoadingState) {
          return const AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        if (state is VideoErrorState) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    Text(state.message,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is VideoReadyState) {
          return _buildPlayer(state.controller);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPlayer(VideoPlayerController controller) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isPlaying   = value.isPlaying;
        final isBuffering = value.isBuffering;
        final position    = value.position;
        final duration    = value.duration;
        final progress    = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;

        return Column(
          children: [
            AspectRatio(
              aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(controller),
                  if (isBuffering)
                    const CircularProgressIndicator(color: Colors.white),
                  GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        _bloc.add(const VideoPauseEvent());
                      } else {
                        _bloc.add(const VideoPlayEvent());
                      }
                    },
                    child: AnimatedOpacity(
                      opacity: isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        color: Colors.black45,
                        child: const Center(
                          child: Icon(Icons.play_circle_outline,
                              color: Colors.white, size: 72),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: [
                  SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 2,
                      thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 5),
                      overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 10),
                      activeTrackColor:   AppTheme.primaryLight,
                      inactiveTrackColor: Colors.white30,
                      thumbColor:         Colors.white,
                      overlayColor:       Colors.white24,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: duration.inMilliseconds > 0
                          ? (v) => _bloc.add(VideoSeekEvent(Duration(
                                milliseconds:
                                    (v * duration.inMilliseconds).round(),
                              )))
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Text(_fmt(position),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const Spacer(),
                        Text(_fmt(duration),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10,
                            color: Colors.white, size: 28),
                        onPressed: () => _bloc.add(VideoSeekEvent(
                            position - const Duration(seconds: 10))),
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            _bloc.add(const VideoPauseEvent());
                          } else {
                            _bloc.add(const VideoPlayEvent());
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10,
                            color: Colors.white, size: 28),
                        onPressed: () => _bloc.add(VideoSeekEvent(
                            position + const Duration(seconds: 10))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
