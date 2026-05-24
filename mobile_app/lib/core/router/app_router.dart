import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../widgets/main_shell.dart';
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../features/admin/presentation/pages/upload_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/creators/domain/entities/creator_entity.dart';
import '../../features/creators/presentation/bloc/creators_bloc.dart';
import '../../features/creators/presentation/pages/creator_form_screen.dart';
import '../../features/creators/presentation/pages/creator_profile_page.dart';
import '../../features/creators/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/works/presentation/pages/work_detail_page.dart';

// ─── Route name constants ──────────────────────────────────────────────────
abstract final class AppRoutes {
  static const splash       = 'splash';
  static const login        = 'login';
  static const register     = 'register';
  static const home         = 'home';
  static const search       = 'search';
  static const profile      = 'profile';
  static const creator      = 'creator';
  static const work         = 'work';
  static const upload       = 'upload';
  static const admin        = 'admin';
  static const creatorForm  = 'creator-form';
}

// ─── ChangeNotifier that fires whenever the auth stream emits ─────────────
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ─── Router ────────────────────────────────────────────────────────────────
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  final _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: _AuthRefreshNotifier(authBloc.stream),
    redirect: _redirect,
    routes: _routes,
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final loc       = state.matchedLocation;
    final authState = authBloc.state;

    if (authState is AuthInitial || authState is AuthLoading) {
      // Login/register sahifasida loading vaqtida redirect qilmaymiz —
      // button ichidagi spinner yetarli. Aks holda BlocListener unmount
      // bo'lib, xato SnackBar ko'rinmay qoladi.
      if (loc == '/login' || loc == '/register') return null;
      return loc == '/splash' ? null : '/splash';
    }

    if (authState is Authenticated) {
      if (loc == '/splash' || loc == '/login' || loc == '/register') {
        return '/home';
      }
      return null;
    }

    if (loc == '/login' || loc == '/register') return null;
    return '/login';
  }

  List<RouteBase> get _routes => [
        GoRoute(
          path:    '/splash',
          name:    AppRoutes.splash,
          builder: (_, __) => const SplashPage(),
        ),
        GoRoute(
          path:    '/login',
          name:    AppRoutes.login,
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path:    '/register',
          name:    AppRoutes.register,
          builder: (_, __) => const RegisterPage(),
        ),

        // Full-screen routes (no BottomNav) — parentNavigatorKey ensures
        // these are pushed on the root navigator, not the shell navigator.
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/creator/:id',
          name: AppRoutes.creator,
          builder: (_, state) => CreatorProfilePage(
            creatorId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/work/:id',
          name: AppRoutes.work,
          builder: (_, state) => WorkDetailPage(
            workId:    state.pathParameters['id']!,
            workTitle: state.uri.queryParameters['title'] ?? '',
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/upload/:creatorId',
          name: AppRoutes.upload,
          builder: (_, state) => UploadScreen(
            creatorId:   state.pathParameters['creatorId']!,
            creatorName: state.uri.queryParameters['name'] ?? '',
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path:    '/admin',
          name:    AppRoutes.admin,
          builder: (_, __) => const AdminDashboard(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path:    '/creator-form',
          name:    AppRoutes.creatorForm,
          builder: (_, state) => CreatorFormScreen(
            existing: state.extra as CreatorEntity?,
          ),
        ),

        // Main shell with BottomNavigationBar
        StatefulShellRoute.indexedStack(
          builder: (_, __, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            // Tab 0: Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: AppRoutes.home,
                  builder: (_, __) => BlocProvider(
                    create: (_) => sl<CreatorsBloc>(),
                    child: const HomePage(),
                  ),
                ),
              ],
            ),

            // Tab 1: Search
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  name: AppRoutes.search,
                  builder: (_, __) => BlocProvider(
                    create: (_) => sl<SearchBloc>(),
                    child: const SearchPage(),
                  ),
                ),
              ],
            ),

            // Tab 2: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: AppRoutes.profile,
                  builder: (_, __) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ];
}
