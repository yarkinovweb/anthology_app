import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/work_detail_entity.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/video_player_bloc.dart';
import '../bloc/work_detail_bloc.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/text_reader_widget.dart';
import '../widgets/video_player_widget.dart';

class WorkDetailPage extends StatelessWidget {
  final String workId;
  final String workTitle;

  const WorkDetailPage({
    super.key,
    required this.workId,
    required this.workTitle,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<WorkDetailBloc>()..add(LoadWorkDetailEvent(workId)),
        ),
        BlocProvider(create: (_) => AudioPlayerBloc()),
        BlocProvider(create: (_) => VideoPlayerBloc()),
      ],
      child: _WorkDetailView(workId: workId, workTitle: workTitle),
    );
  }
}

class _WorkDetailView extends StatelessWidget {
  final String workId;
  final String workTitle;
  const _WorkDetailView({required this.workId, required this.workTitle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkDetailBloc, WorkDetailState>(
      builder: (context, state) {
        if (state is WorkDetailInitial || state is WorkDetailLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(workTitle,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is WorkDetailError) {
          return Scaffold(
            appBar: AppBar(title: Text(workTitle)),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: AppTheme.textMuted),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<WorkDetailBloc>()
                        .add(LoadWorkDetailEvent(workId)),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is WorkDetailLoaded) {
          return _buildLoaded(context, state.work);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoaded(BuildContext context, WorkDetailEntity work) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          context.read<WorkDetailBloc>().add(LoadWorkDetailEvent(workId));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            title: Text(
              work.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media player
                if (work.isVideo && work.hasMedia)
                  VideoPlayerWidget(url: work.mediaUrl!)
                else if (work.isAudio && work.hasMedia)
                  AudioPlayerWidget(url: work.mediaUrl!, title: work.title)
                else if (work.isImage && work.hasMedia)
                  _ImageView(url: work.mediaUrl!),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta chips row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _TypeChip(mediaType: work.mediaType),
                          if (work.creatorName != null)
                            _InfoChip(
                              icon: Icons.person_outline,
                              label: work.creatorName!,
                            ),
                        ],
                      ),

                      if (work.description != null &&
                          work.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Parchment description box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLight,
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                              left: BorderSide(
                                  color: AppTheme.accentDark, width: 3),
                            ),
                          ),
                          child: Text(
                            work.description!,
                            style: const TextStyle(
                              fontSize:  14,
                              color:     AppTheme.textDark,
                              height:    1.65,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],

                      if (work.hasText) ...[
                        const SizedBox(height: 24),
                        // Ornamental section header
                        Row(
                          children: [
                            Container(
                                width: 20, height: 1,
                                color: AppTheme.accent.withAlpha(120)),
                            const SizedBox(width: 8),
                            const Icon(Icons.auto_stories,
                                size: 14, color: AppTheme.accent),
                            const SizedBox(width: 8),
                            Text(
                              'works_content'.tr(),
                              style: const TextStyle(
                                fontSize:      12,
                                color:         AppTheme.accentDark,
                                fontWeight:    FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                  height: 1,
                                  color: AppTheme.accent.withAlpha(120)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextReaderWidget(text: work.contentText!),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _ImageView extends StatelessWidget {
  final String url;
  const _ImageView({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
      errorBuilder: (_, __, ___) => const SizedBox(
        height: 200,
        child: Center(
          child: Icon(Icons.broken_image, size: 64, color: AppTheme.textMuted),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String mediaType;
  const _TypeChip({required this.mediaType});

  static const _icons = {
    'video': Icons.play_circle_outline,
    'audio': Icons.music_note_outlined,
    'image': Icons.image_outlined,
    'pdf':   Icons.picture_as_pdf_outlined,
  };

  static const _colors = {
    'video': Color(0xFF4A1525),
    'audio': Color(0xFF7B3048),
    'image': Color(0xFFB8941F),
    'pdf':   Color(0xFF5C2030),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[mediaType] ?? AppTheme.primary;
    final icon  = _icons[mediaType] ?? Icons.attachment;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            mediaType.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
