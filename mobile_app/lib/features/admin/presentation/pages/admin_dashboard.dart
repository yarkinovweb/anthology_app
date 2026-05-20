import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../bloc/admin_data_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/moderation_bloc.dart';
import '../bloc/user_management_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final role = authState is Authenticated ? authState.user.role : '';

    if (role == 'admin') {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                sl<DashboardBloc>()..add(const FetchDashboardStatsEvent()),
          ),
          BlocProvider(
            create: (_) =>
                sl<UserManagementBloc>()..add(const FetchUsersEvent()),
          ),
          BlocProvider(
            create: (_) =>
                sl<AdminDataBloc>()..add(const FetchAdminDataEvent()),
          ),
        ],
        child: const _AdminView(),
      );
    }

    return BlocProvider(
      create: (_) =>
          sl<ModerationBloc>()..add(const FetchPendingWorksEvent()),
      child: const _SpecialistView(),
    );
  }
}

// ─── Admin view: tablar bilan ─────────────────────────────────────────────────

class _AdminView extends StatelessWidget {
  const _AdminView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: Text(
            'admin_dashboard_title'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<DashboardBloc>().add(const FetchDashboardStatsEvent());
                context.read<UserManagementBloc>().add(const FetchUsersEvent());
                context.read<AdminDataBloc>().add(const FetchAdminDataEvent());
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'admin_tab_overview'.tr()),
              Tab(text: 'admin_tab_works'.tr()),
              Tab(text: 'admin_tab_creators'.tr()),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _WorksTab(),
            _CreatorsTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 0: Overview — Stats + Users ────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StatsSection(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'admin_users_title'.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ),
        const Expanded(child: _UserListSection()),
      ],
    );
  }
}

// ─── Tab 1: Works ─────────────────────────────────────────────────────────────

class _WorksTab extends StatelessWidget {
  const _WorksTab();

  static const Map<String, Color> _typeColors = {
    'video': Color(0xFF4A1525),
    'audio': Color(0xFF7B3048),
    'image': Color(0xFFB8941F),
    'pdf':   Color(0xFF5C2030),
  };

  static const Map<String, IconData> _typeIcons = {
    'video': Icons.play_circle_outline,
    'audio': Icons.music_note_outlined,
    'image': Icons.image_outlined,
    'pdf':   Icons.picture_as_pdf_outlined,
  };

  static const Map<String, Color> _statusColors = {
    'approved': Color(0xFF2E7D32),
    'pending':  Color(0xFFE65100),
    'rejected': Color(0xFFC62828),
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDataBloc, AdminDataState>(
      builder: (context, state) {
        if (state is AdminDataInitialState || state is AdminDataLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminDataErrorState) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context
                .read<AdminDataBloc>()
                .add(const FetchAdminDataEvent()),
          );
        }
        if (state is AdminDataLoadedState) {
          final works = state.works;
          if (works.isEmpty) {
            return Center(child: Text('search_no_results'.tr(),
                style: const TextStyle(color: AppTheme.textMuted)));
          }
          return RefreshIndicator(
            onRefresh: () async => context
                .read<AdminDataBloc>()
                .add(const FetchAdminDataEvent()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: works.length,
              itemBuilder: (_, i) =>
                  _WorkTile(work: works[i], typeColors: _typeColors,
                      typeIcons: _typeIcons, statusColors: _statusColors),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _WorkTile extends StatelessWidget {
  final WorkDetailEntity work;
  final Map<String, Color> typeColors;
  final Map<String, IconData> typeIcons;
  final Map<String, Color> statusColors;

  const _WorkTile({
    required this.work,
    required this.typeColors,
    required this.typeIcons,
    required this.statusColors,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor  = typeColors[work.mediaType]  ?? AppTheme.primary;
    final typeIcon   = typeIcons[work.mediaType]   ?? Icons.attachment;
    final statusColor = statusColors[work.status ?? ''] ?? AppTheme.textMuted;
    final statusKey = work.status == 'approved'
        ? 'works_status_approved'
        : work.status == 'pending'
            ? 'works_status_pending'
            : 'works_status_rejected';

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.work,
        pathParameters: {'id': work.id},
        queryParameters: {'title': work.title},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (work.creatorName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        work.creatorName!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withAlpha(60)),
                ),
                child: Text(
                  statusKey.tr(),
                  style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab 2: Creators ─────────────────────────────────────────────────────────

class _CreatorsTab extends StatelessWidget {
  const _CreatorsTab();

  static const List<Color> _avatarColors = [
    Color(0xFF4A1525), Color(0xFF6B2737), Color(0xFF7D3945),
    Color(0xFF5C2030), Color(0xFF3D1020), Color(0xFF8B3A4A),
  ];

  Color _avatarColor(String name) =>
      _avatarColors[name.codeUnitAt(0) % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDataBloc, AdminDataState>(
      builder: (context, state) {
        if (state is AdminDataInitialState || state is AdminDataLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminDataErrorState) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context
                .read<AdminDataBloc>()
                .add(const FetchAdminDataEvent()),
          );
        }
        if (state is AdminDataLoadedState) {
          final creators = state.creators;
          if (creators.isEmpty) {
            return Center(child: Text('search_no_results'.tr(),
                style: const TextStyle(color: AppTheme.textMuted)));
          }
          return RefreshIndicator(
            onRefresh: () async => context
                .read<AdminDataBloc>()
                .add(const FetchAdminDataEvent()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: creators.length,
              itemBuilder: (_, i) =>
                  _CreatorTile(creator: creators[i],
                      color: _avatarColor(creators[i].name)),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _CreatorTile extends StatelessWidget {
  final CreatorEntity creator;
  final Color color;

  const _CreatorTile({required this.creator, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.creator,
        pathParameters: {'id': creator.id},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withAlpha(30),
            child: Text(
              creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            creator.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Row(
            children: [
              if (creator.countryName != null) ...[
                Flexible(
                  child: Text(
                    '${creator.flagEmoji ?? ''} ${creator.countryName!}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (creator.categoryName != null &&
                  creator.countryName != null)
                const Text('  ·  ',
                    style: TextStyle(color: AppTheme.textMuted)),
              if (creator.categoryName != null)
                Flexible(
                  child: Text(
                    creator.categoryName!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          trailing: Text(
            creator.lifespan,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textMuted),
          ),
        ),
      ),
    );
  }
}

// ─── Specialist view ──────────────────────────────────────────────────────────

class _SpecialistView extends StatelessWidget {
  const _SpecialistView();

  static const Map<String, Color> _typeColors = {
    'video': Color(0xFF4A1525),
    'audio': Color(0xFF7B3048),
    'image': Color(0xFFB8941F),
    'pdf':   Color(0xFF5C2030),
  };

  static const Map<String, IconData> _typeIcons = {
    'video': Icons.play_circle_outline,
    'audio': Icons.music_note_outlined,
    'image': Icons.image_outlined,
    'pdf':   Icons.picture_as_pdf_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          'admin_pending'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<ModerationBloc>().add(const FetchPendingWorksEvent()),
          ),
        ],
      ),
      body: _ModerationList(typeColors: _typeColors, typeIcons: _typeIcons),
    );
  }
}

// ─── Stats Cards ─────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoadingState || state is DashboardInitialState) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is DashboardErrorState) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppTheme.textMuted, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(state.message,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13)),
                ),
                TextButton(
                  onPressed: () => context
                      .read<DashboardBloc>()
                      .add(const FetchDashboardStatsEvent()),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }
        if (state is DashboardLoadedState) {
          final s = state.stats;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                _StatCard(label: 'stats_total_users'.tr(),
                    value: s.totalUsers,
                    icon: Icons.people_outline,
                    color: AppTheme.primary),
                _StatCard(label: 'stats_approved_creators'.tr(),
                    value: s.approvedCreators,
                    icon: Icons.person_pin_outlined,
                    color: AppTheme.accentDark),
                _StatCard(label: 'stats_total_works'.tr(),
                    value: s.totalWorks,
                    icon: Icons.library_books_outlined,
                    color: AppTheme.primaryLight),
                _StatCard(label: 'stats_pending_works'.tr(),
                    value: s.pendingWorks,
                    icon: Icons.pending_actions_outlined,
                    color: AppTheme.error),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWarm,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value.toString(),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color,
                            height: 1.1)),
                  ),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── User List Section ────────────────────────────────────────────────────────

class _UserListSection extends StatelessWidget {
  const _UserListSection();

  static const Map<String, Color> _roleColors = {
    'admin':      AppTheme.primary,
    'specialist': Color(0xFF2E7D32),
    'researcher': AppTheme.accentDark,
    'user':       AppTheme.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementBloc, UserManagementState>(
      builder: (context, state) {
        if (state is UserManagementInitialState ||
            state is UserManagementLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserManagementErrorState) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context
                .read<UserManagementBloc>()
                .add(const FetchUsersEvent()),
          );
        }
        if (state is UserManagementLoadedState) {
          return RefreshIndicator(
            onRefresh: () async => context
                .read<UserManagementBloc>()
                .add(const FetchUsersEvent()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: state.users.length,
              itemBuilder: (_, i) {
                final user = state.users[i];
                final isPromoting = state.promotingIds.contains(user.id);
                final roleColor =
                    _roleColors[user.role] ?? AppTheme.textMuted;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: roleColor.withAlpha(30),
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(user.email,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted)),
                    trailing: SizedBox(
                      width: 110,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: roleColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: roleColor.withAlpha(60)),
                              ),
                              child: Text(
                                _roleKey(user.role).tr(),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: roleColor,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (user.isPromotable) ...[
                            const SizedBox(width: 4),
                            isPromoting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primary))
                                : IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
                                    icon: const Icon(
                                        Icons.arrow_circle_up_outlined,
                                        color: AppTheme.primary,
                                        size: 22),
                                    tooltip:
                                        'admin_promote_tooltip'.tr(),
                                    onPressed: () => context
                                        .read<UserManagementBloc>()
                                        .add(PromoteUserEvent(user.id)),
                                  ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _roleKey(String role) {
    switch (role) {
      case 'admin':      return 'role_admin';
      case 'specialist': return 'role_specialist';
      case 'researcher': return 'role_researcher';
      case 'user':       return 'role_user';
      default:           return role;
    }
  }
}

// ─── Moderation List (Specialist) ────────────────────────────────────────────

class _ModerationList extends StatelessWidget {
  final Map<String, Color> typeColors;
  final Map<String, IconData> typeIcons;

  const _ModerationList({required this.typeColors, required this.typeIcons});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModerationBloc, ModerationState>(
      builder: (context, state) {
        if (state is ModerationInitialState || state is ModerationLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ModerationErrorState) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context
                .read<ModerationBloc>()
                .add(const FetchPendingWorksEvent()),
          );
        }
        if (state is ModerationLoadedState) {
          if (state.works.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: AppTheme.primary),
                  const SizedBox(height: 12),
                  Text('admin_no_pending'.tr(),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 16)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => context
                .read<ModerationBloc>()
                .add(const FetchPendingWorksEvent()),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: state.works.length,
              itemBuilder: (_, i) {
                final work = state.works[i];
                final isProcessing =
                    state.processingIds.contains(work.id);
                final typeColor =
                    typeColors[work.mediaType] ?? AppTheme.primary;
                final typeIcon =
                    typeIcons[work.mediaType] ?? Icons.attachment;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: typeColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(typeIcon,
                                  color: typeColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(work.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppTheme.textDark),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  if (work.creatorName != null) ...[
                                    const SizedBox(height: 2),
                                    Text(work.creatorName!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textMuted)),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: typeColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: typeColor.withAlpha(60)),
                              ),
                              child: Text(
                                work.mediaType.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: typeColor,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        if (work.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 10),
                          Text(work.description!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis),
                        ],
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        isProcessing
                            ? const Center(
                                child: SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primary),
                                ),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                          Icons.close, size: 16),
                                      label:
                                          Text('admin_reject'.tr()),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                            color: Colors.red),
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                      ),
                                      onPressed: () => context
                                          .read<ModerationBloc>()
                                          .add(RejectWorkEvent(work.id)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(
                                          Icons.check, size: 16),
                                      label: Text('admin_approve'.tr()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                      ),
                                      onPressed: () => context
                                          .read<ModerationBloc>()
                                          .add(ApproveWorkEvent(work.id)),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Shared Error Widget ──────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppTheme.textMuted),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }
}
