import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await configureDependencies();

  // Birinchi ishga tushirishda default til o'zbekcha
  if (sl<HiveStorage>().getLanguage() == null) {
    await sl<HiveStorage>().saveLanguage('uz');
  }

  final authBloc  = sl<AuthBloc>()..add(const AuthCheckRequested());
  final appRouter = AppRouter(authBloc);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('uz'),
        Locale('tr'),
        Locale('az'),
        Locale('kk'),
        Locale('ky'),
        Locale('en'),
        Locale('ru'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('uz'),
      child: BlocProvider.value(
        value: authBloc,
        child: AnthologyApp(router: appRouter.router),
      ),
    ),
  );
}

class AnthologyApp extends StatelessWidget {
  final GoRouter router;
  const AnthologyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'app_name'.tr(),
      theme: AppTheme.light,
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
