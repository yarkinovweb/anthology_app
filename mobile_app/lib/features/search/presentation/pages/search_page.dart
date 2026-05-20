import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../bloc/search_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchBloc>()
        ..add(SearchCreatorsEvent(query))
        ..add(SearchWorksEvent(query));
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {});
    context.read<SearchBloc>()
      ..add(const SearchCreatorsEvent(''))
      ..add(const SearchWorksEvent(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        titleSpacing: 8,
        title: TextField(
          controller: _searchCtrl,
          onChanged:  _onChanged,
          autofocus:  true,
          style:      const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: AppTheme.accent,
          decoration: InputDecoration(
            hintText:  'search_hint'.tr(),
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 15),
            border:    InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              final creatorsCount =
                  state is SearchSuccessState ? state.creators.length : 0;
              final worksCount =
                  state is SearchSuccessState ? state.works.length : 0;
              return TabBar(
                controller:          _tabController,
                indicatorColor:      AppTheme.accent,
                indicatorWeight:     2.5,
                labelColor:          Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 13, letterSpacing: 0.3),
                tabs: [
                  Tab(
                    text: creatorsCount > 0
                        ? '${'search_tab_creators'.tr()} ($creatorsCount)'
                        : 'search_tab_creators'.tr(),
                  ),
                  Tab(
                    text: worksCount > 0
                        ? '${'search_tab_works'.tr()} ($worksCount)'
                        : 'search_tab_works'.tr(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitialState) return _buildPrompt();
          if (state is SearchSuccessState) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildCreatorsTab(state),
                _buildWorksTab(state),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPrompt() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withAlpha(12),
              border: Border.all(color: AppTheme.accent.withAlpha(60)),
            ),
            child: const Icon(Icons.search, size: 38, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'search_prompt'.tr(),
            style: const TextStyle(
              color:       AppTheme.textMuted,
              fontSize:    15,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            'search_no_results'.tr(),
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorsTab(SearchSuccessState state) {
    if (state.creatorsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (state.creators.isEmpty) return _buildNoResults();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: state.creators.length,
      itemBuilder: (_, i) => _CreatorTile(
        creator: state.creators[i],
        onTap:   () => context.pushNamed(
          AppRoutes.creator,
          pathParameters: {'id': state.creators[i].id},
        ),
      ),
    );
  }

  Widget _buildWorksTab(SearchSuccessState state) {
    if (state.worksLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (state.works.isEmpty) return _buildNoResults();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: state.works.length,
      itemBuilder: (_, i) => _WorkTile(
        work:  state.works[i],
        onTap: () => context.pushNamed(
          AppRoutes.work,
          pathParameters:  {'id': state.works[i].id},
          queryParameters: {'title': state.works[i].title},
        ),
      ),
    );
  }
}

// ─── Creator tile ─────────────────────────────────────────────────────────────

class _CreatorTile extends StatelessWidget {
  final CreatorEntity creator;
  final VoidCallback onTap;

  const _CreatorTile({required this.creator, required this.onTap});

  static const List<Color> _colors = [
    Color(0xFF4A1525), Color(0xFF6B2737), Color(0xFF7D3945),
    Color(0xFF5C2030), Color(0xFF3D1020), Color(0xFF8B3A4A),
  ];

  Color get _avatarColor =>
      _colors[creator.name.codeUnitAt(0) % _colors.length];

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceWarm,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Gold-ringed avatar
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentDark],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: color,
                    child: Text(
                      creator.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator.name,
                        style: const TextStyle(
                          fontWeight:    FontWeight.w700,
                          fontSize:      14,
                          color:         AppTheme.textDark,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (creator.flagEmoji != null)
                            Text('${creator.flagEmoji} ',
                                style: const TextStyle(fontSize: 12)),
                          if (creator.categoryName != null)
                            Expanded(
                              child: Text(
                                creator.categoryName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:    color,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (creator.lifespan.isNotEmpty)
                            Text(
                              creator.lifespan,
                              style: const TextStyle(
                                fontSize:  11,
                                color:     AppTheme.textLight,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Work tile ────────────────────────────────────────────────────────────────

class _WorkTile extends StatelessWidget {
  final WorkDetailEntity work;
  final VoidCallback onTap;

  const _WorkTile({required this.work, required this.onTap});

  static const Map<String, IconData> _typeIcons = {
    'video': Icons.play_circle_outline,
    'audio': Icons.music_note_outlined,
    'image': Icons.image_outlined,
    'pdf':   Icons.picture_as_pdf_outlined,
    'text':  Icons.article_outlined,
  };

  static const Map<String, Color> _typeColors = {
    'video': Color(0xFF4A1525),
    'audio': Color(0xFF7B3048),
    'image': Color(0xFFB8941F),
    'pdf':   Color(0xFF5C2030),
    'text':  Color(0xFF7A6652),
  };

  @override
  Widget build(BuildContext context) {
    final typeKey = work.mediaType.toLowerCase();
    final icon    = _typeIcons[typeKey]  ?? Icons.insert_drive_file_outlined;
    final color   = _typeColors[typeKey] ?? AppTheme.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: color, width: 3),
              top:    const BorderSide(color: AppTheme.cardBorder),
              right:  const BorderSide(color: AppTheme.cardBorder),
              bottom: const BorderSide(color: AppTheme.cardBorder),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width:  38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:         color.withAlpha(20),
                    borderRadius:  BorderRadius.circular(8),
                    border:        Border.all(color: color.withAlpha(50)),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize:   14,
                          color:      AppTheme.textDark,
                          letterSpacing: 0.1,
                        ),
                        maxLines:  1,
                        overflow:  TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (work.creatorName != null)
                        Text(
                          work.creatorName!,
                          style: TextStyle(
                            fontSize:   12,
                            color:      color,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (work.description != null &&
                          work.description!.isNotEmpty)
                        Text(
                          work.description!,
                          style: const TextStyle(
                            fontSize:  11,
                            color:     AppTheme.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color:         color.withAlpha(15),
                    borderRadius:  BorderRadius.circular(6),
                  ),
                  child: Text(
                    work.mediaType.toUpperCase(),
                    style: TextStyle(
                      fontSize:   9,
                      color:      color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
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
