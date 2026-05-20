import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user      = authState is Authenticated ? authState.user : null;
    final isAdmin   = user?.isAdmin   ?? false;
    final isSpecialist = user?.isSpecialist ?? false;
    final hasPanel  = isAdmin || isSpecialist;

    final panelLabel = isAdmin
        ? 'admin_panel_btn'.tr()
        : 'specialist_panel_btn'.tr();
    final panelIcon  = isAdmin
        ? Icons.dashboard_outlined
        : Icons.fact_check_outlined;
    final panelActiveIcon = isAdmin
        ? Icons.dashboard
        : Icons.fact_check;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          if (hasPanel && index == 3) {
            context.pushNamed(AppRoutes.admin);
            return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        selectedItemColor:    AppTheme.primary,
        unselectedItemColor:  AppTheme.textMuted,
        backgroundColor:      Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon:       const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label:      'nav_home'.tr(),
          ),
          BottomNavigationBarItem(
            icon:  const Icon(Icons.search),
            label: 'nav_search'.tr(),
          ),
          BottomNavigationBarItem(
            icon:       const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label:      'nav_profile'.tr(),
          ),
          if (hasPanel)
            BottomNavigationBarItem(
              icon:       Icon(panelIcon),
              activeIcon: Icon(panelActiveIcon),
              label:      panelLabel,
            ),
        ],
      ),
    );
  }
}
