import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/entities/creator_filters.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/creators_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl        = TextEditingController();
  Timer? _debounce;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CreatorsBloc>().add(const FetchCreatorsEvent());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<CreatorsBloc>().add(SearchCreatorsEvent(query));
    });
  }

  Future<void> _refresh() async {
    context.read<CreatorsBloc>().add(const FetchCreatorsEvent());
  }

  void _applyFilters({String? categoryId, bool clear = false}) {
    if (clear) {
      setState(() {
        _selectedCategoryId = null;
        _searchCtrl.clear();
      });
      context.read<CreatorsBloc>().add(const FetchCreatorsEvent());
      return;
    }
    setState(() => _selectedCategoryId = categoryId);
    final current  = context.read<CreatorsBloc>().state;
    final existing = current is CreatorsLoaded ? current.activeFilters : const CreatorFilters();
    context.read<CreatorsBloc>().add(
          FetchCreatorsEvent(
            filters: existing.copyWith(
              categoryId:    categoryId,
              clearCategory: categoryId == null,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final canManage = authState is Authenticated && authState.user.canManageCreators;

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: canManage
          ? FloatingActionButton(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.primaryDark,
              tooltip: 'creator_create_title'.tr(),
              onPressed: () async {
                final bloc = context.read<CreatorsBloc>();
                await context.pushNamed(AppRoutes.creatorForm);
                bloc.add(const FetchCreatorsEvent());
              },
              child: const Icon(Icons.person_add_outlined),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildSliverAppBar()],
        body: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(child: _buildCreatorsBody()),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap:     true,
      backgroundColor: AppTheme.primary,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'app_name'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'creators_title'.tr(),
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.language, color: Colors.white),
          onSelected: (lang) {
            context.setLocale(Locale(lang));
            sl<HiveStorage>().saveLanguage(lang);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'uz', child: Text("O'zbek")),
            PopupMenuItem(value: 'tr', child: Text('Türkçe')),
            PopupMenuItem(value: 'az', child: Text('Azərbaycan')),
            PopupMenuItem(value: 'kk', child: Text('Қазақша')),
            PopupMenuItem(value: 'ky', child: Text('Кыргызча')),
            PopupMenuItem(value: 'en', child: Text('English')),
            PopupMenuItem(value: 'ru', child: Text('Русский')),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
        cursorColor: AppTheme.accent,
        decoration: InputDecoration(
          hintText: 'search_hint'.tr(),
          hintStyle: TextStyle(color: AppTheme.textMuted.withAlpha(180), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  color: AppTheme.textMuted,
                  onPressed: () {
                    _searchCtrl.clear();
                    context.read<CreatorsBloc>().add(const SearchCreatorsEvent(''));
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.surfaceWarm,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<CreatorsBloc, CreatorsState>(
      builder: (context, state) {
        if (state is! CreatorsLoaded) return const SizedBox.shrink();
        return SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _CategoryChip(
                label: 'creators_all'.tr(),
                selected: _selectedCategoryId == null,
                onSelected: (_) => _applyFilters(clear: true),
              ),
              ...state.categories.map(
                (cat) => _CategoryChip(
                  label: cat.name,
                  selected: _selectedCategoryId == cat.id,
                  onSelected: (_) => _applyFilters(
                    categoryId: _selectedCategoryId == cat.id ? null : cat.id,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreatorsBody() {
    return BlocBuilder<CreatorsBloc, CreatorsState>(
      builder: (context, state) {
        if (state is CreatorsLoading || state is CreatorsInitial) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (state is CreatorsError) {
          return _ErrorBody(
            message: state.message,
            onRetry: () => context.read<CreatorsBloc>().add(const FetchCreatorsEvent()),
          );
        }
        if (state is CreatorsLoaded) {
          if (state.creators.isEmpty) {
            return LayoutBuilder(
              builder: (_, constraints) => RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 56, color: AppTheme.textMuted.withAlpha(100)),
                          const SizedBox(height: 12),
                          Text(
                            'search_no_results'.tr(),
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: _refresh,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:   2,
                crossAxisSpacing: 12,
                mainAxisSpacing:  12,
                childAspectRatio: 0.62,
              ),
              itemCount: state.creators.length,
              itemBuilder: (_, i) => _CreatorCard(
                creator: state.creators[i],
                onTap:   () => context.pushNamed(
                  AppRoutes.creator,
                  pathParameters: {'id': state.creators[i].id},
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Category chip ────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceWarm,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.cardBorder,
          ),
        ),
        child: InkWell(
          onTap: () => onSelected(!selected),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textDark,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Portrait creator card ────────────────────────────────────────────────────

class _CreatorCard extends StatelessWidget {
  final CreatorEntity creator;
  final VoidCallback onTap;

  const _CreatorCard({required this.creator, required this.onTap});

  static const List<Color> _avatarColors = [
    Color(0xFF4A1525), Color(0xFF6B2737), Color(0xFF7D3945),
    Color(0xFF5C2030), Color(0xFF3D1020), Color(0xFF8B3A4A),
  ];

  Color _avatarColor(String name) =>
      _avatarColors[name.codeUnitAt(0) % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(creator.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWarm,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAlpha(14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Oval avatar with gold ring ──
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withAlpha(200)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      creator.name[0].toUpperCase(),
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // ── Ornamental divider ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 20, height: 1, color: AppTheme.accent.withAlpha(120)),
                  const SizedBox(width: 5),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withAlpha(180),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(width: 20, height: 1, color: AppTheme.accent.withAlpha(120)),
                ],
              ),
              const SizedBox(height: 9),
              // ── Name ──
              Text(
                creator.name,
                style: const TextStyle(
                  fontWeight:    FontWeight.w700,
                  fontSize:      13,
                  color:         AppTheme.textDark,
                  letterSpacing: 0.1,
                  height:        1.3,
                ),
                textAlign:    TextAlign.center,
                maxLines:     2,
                overflow:     TextOverflow.ellipsis,
              ),
              // ── Category ──
              if (creator.categoryName != null) ...[
                const SizedBox(height: 5),
                Text(
                  creator.categoryName!,
                  style: TextStyle(
                    fontSize:      11,
                    color:         color,
                    fontWeight:    FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines:  1,
                  overflow:  TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              // ── Country ──
              if (creator.countryName != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize:      MainAxisSize.min,
                  children: [
                    if (creator.flagEmoji != null)
                      Text(creator.flagEmoji!, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        creator.countryName!,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              // ── Lifespan ──
              if (creator.lifespan.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  creator.lifespan,
                  style: const TextStyle(
                    fontSize:    10,
                    color:       AppTheme.textLight,
                    fontStyle:   FontStyle.italic,
                    letterSpacing: 0.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text('retry'.tr())),
        ],
      ),
    );
  }
}
