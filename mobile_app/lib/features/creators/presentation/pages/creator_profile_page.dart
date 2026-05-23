import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/entities/work_preview_entity.dart';
import '../bloc/creator_detail_bloc.dart';

class CreatorProfilePage extends StatelessWidget {
  final String creatorId;

  const CreatorProfilePage({super.key, required this.creatorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CreatorDetailBloc>()..add(LoadCreatorDetailEvent(creatorId)),
      child: _CreatorProfileView(creatorId: creatorId),
    );
  }
}

class _CreatorProfileView extends StatelessWidget {
  final String creatorId;
  const _CreatorProfileView({required this.creatorId});

  static const List<Color> _avatarColors = [
    Color(0xFF4A1525), Color(0xFF6B2737), Color(0xFF7D3945),
    Color(0xFF5C2030), Color(0xFF3D1020), Color(0xFF8B3A4A),
  ];

  Color _avatarColor(String name) =>
      _avatarColors[name.codeUnitAt(0) % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatorDetailBloc, CreatorDetailState>(
      builder: (context, state) {
        if (state is CreatorDetailLoading || state is CreatorDetailInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CreatorDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<CreatorDetailBloc>()
                        .add(LoadCreatorDetailEvent(
                            (context.read<CreatorDetailBloc>().state
                                    as CreatorDetailError)
                                .message)),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CreatorDetailLoaded) {
          return _buildLoaded(context, state.creator);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoaded(BuildContext context, CreatorEntity creator) {
    final color = _avatarColor(creator.name);

    final authState = context.read<AuthBloc>().state;
    final canUpload  = authState is Authenticated && authState.user.canUpload;
    final canManage  = authState is Authenticated && authState.user.canManageCreators;

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: canUpload
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file),
              label: Text('works_upload'.tr()),
              onPressed: () => context
                  .pushNamed(
                    AppRoutes.upload,
                    pathParameters: {'creatorId': creator.id},
                    queryParameters: {'name': creator.name},
                  )
                  .then((_) {
                if (context.mounted) {
                  context
                      .read<CreatorDetailBloc>()
                      .add(LoadCreatorDetailEvent(creatorId));
                }
              }),
            )
          : null,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          context.read<CreatorDetailBloc>().add(LoadCreatorDetailEvent(creatorId));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, creator, color, canManage: canManage),
            SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMeta(creator, color),
                  if (creator.bio != null && creator.bio!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildBioSection(context, creator.bio!),
                  ],
                  const SizedBox(height: 24),
                  _buildWorksSection(context, creator.works),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, CreatorEntity creator, Color color,
      {bool canManage = false}) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: color,
      foregroundColor: Colors.white,
      actions: canManage
          ? [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'edit'.tr(),
                onPressed: () => context
                    .pushNamed(
                      AppRoutes.creatorForm,
                      extra: creator,
                    )
                    .then((updated) {
                  if (updated != null && context.mounted) {
                    context
                        .read<CreatorDetailBloc>()
                        .add(LoadCreatorDetailEvent(creator.id));
                  }
                }),
              ),
            ]
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withAlpha(200)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white24,
                child: Text(
                  creator.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                creator.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (creator.lifespan.isNotEmpty)
                Text(
                  creator.lifespan,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeta(CreatorEntity creator, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (creator.categoryName != null)
          _MetaChip(
            icon: Icons.category_outlined,
            label: creator.categoryName!,
            color: color,
          ),
        if (creator.countryName != null)
          _MetaChip(
            label: '${creator.flagEmoji ?? ''} ${creator.countryName!}',
            color: AppTheme.primaryLight,
          ),
      ],
    );
  }

  Widget _buildBioSection(BuildContext context, String bio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'creators_bio'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentLight,
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(color: AppTheme.accent, width: 3),
            ),
          ),
          child: Text(
            bio,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppTheme.textDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorksSection(
      BuildContext context, List<WorkPreviewEntity> works) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('creators_works'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${works.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (works.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('search_no_results'.tr(),
                  style: const TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          ...works.map((work) => _WorkTile(
                work: work,
                onTap: () => context.pushNamed(
                  AppRoutes.work,
                  pathParameters: {'id': work.id},
                  queryParameters: {'title': work.title},
                ),
              )),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _MetaChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
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
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _WorkTile extends StatelessWidget {
  final WorkPreviewEntity work;
  final VoidCallback onTap;

  const _WorkTile({required this.work, required this.onTap});

  static const Map<String, IconData> _icons = {
    'video': Icons.play_circle_outline,
    'audio': Icons.music_note_outlined,
    'image': Icons.image_outlined,
    'pdf':   Icons.picture_as_pdf_outlined,
    'text':  Icons.article_outlined,
  };

  static const Map<String, Color> _colors = {
    'video': Color(0xFF4A1525),
    'audio': Color(0xFF7B3048),
    'image': Color(0xFFB8941F),
    'pdf':   Color(0xFF5C2030),
    'text':  Color(0xFF7A6652),
  };

  @override
  Widget build(BuildContext context) {
    final icon  = _icons[work.mediaType]  ?? Icons.auto_stories;
    final color = _colors[work.mediaType] ?? AppTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color:        color.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                work.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize:   14,
                                  color:      AppTheme.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (work.description != null &&
                                  work.description!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  work.description!,
                                  style: const TextStyle(
                                    fontSize:  12,
                                    color:     AppTheme.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppTheme.textMuted, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
