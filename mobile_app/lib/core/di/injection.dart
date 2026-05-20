import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../storage/hive_storage.dart';

// Profile
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/fetch_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Admin
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/get_admin_creators_usecase.dart';
import '../../features/admin/domain/usecases/get_admin_works_usecase.dart';
import '../../features/admin/domain/usecases/get_dashboard_stats_usecase.dart';
import '../../features/admin/domain/usecases/get_pending_works_usecase.dart';
import '../../features/admin/domain/usecases/get_users_usecase.dart';
import '../../features/admin/domain/usecases/promote_user_usecase.dart';
import '../../features/admin/domain/usecases/update_work_status_usecase.dart';
import '../../features/admin/domain/usecases/upload_work_usecase.dart';
import '../../features/admin/presentation/bloc/admin_data_bloc.dart';
import '../../features/admin/presentation/bloc/dashboard_bloc.dart';
import '../../features/admin/presentation/bloc/moderation_bloc.dart';
import '../../features/admin/presentation/bloc/upload_bloc.dart';
import '../../features/admin/presentation/bloc/user_management_bloc.dart';

// Search
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_creators_usecase.dart';
import '../../features/search/domain/usecases/search_works_usecase.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';

// Works
import '../../features/works/data/datasources/works_remote_datasource.dart';
import '../../features/works/data/repositories/works_repository_impl.dart';
import '../../features/works/domain/repositories/works_repository.dart';
import '../../features/works/domain/usecases/get_work_detail_usecase.dart';
import '../../features/works/presentation/bloc/work_detail_bloc.dart';

// Creators
import '../../features/creators/data/datasources/creators_remote_datasource.dart';
import '../../features/creators/data/repositories/creators_repository_impl.dart';
import '../../features/creators/domain/repositories/creators_repository.dart';
import '../../features/creators/domain/usecases/create_creator_usecase.dart';
import '../../features/creators/domain/usecases/delete_creator_usecase.dart';
import '../../features/creators/domain/usecases/get_categories_usecase.dart';
import '../../features/creators/domain/usecases/get_countries_usecase.dart';
import '../../features/creators/domain/usecases/get_creator_detail_usecase.dart';
import '../../features/creators/domain/usecases/get_creators_usecase.dart';
import '../../features/creators/domain/usecases/update_creator_usecase.dart';
import '../../features/creators/presentation/bloc/creator_detail_bloc.dart';
import '../../features/creators/presentation/bloc/creator_manage_bloc.dart';
import '../../features/creators/presentation/bloc/creators_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ─── Core ─────────────────────────────────────────────────────────────────
  final hiveStorage = HiveStorage();
  await hiveStorage.init();
  sl.registerSingleton<HiveStorage>(hiveStorage);
  sl.registerSingleton<DioClient>(DioClient(sl<HiveStorage>()));

  // ─── Auth ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<DioClient>()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<HiveStorage>()));
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => AuthBloc(
        login:     sl<LoginUseCase>(),
        register:  sl<RegisterUseCase>(),
        checkAuth: sl<CheckAuthUseCase>(),
        logout:    sl<LogoutUseCase>(),
      ));

  // ─── Creators ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CreatorsRemoteDataSource>(
      () => CreatorsRemoteDataSourceImpl(sl<DioClient>()));
  sl.registerLazySingleton<CreatorsRepository>(
      () => CreatorsRepositoryImpl(sl<CreatorsRemoteDataSource>()));
  sl.registerLazySingleton(() => GetCreatorsUseCase(sl<CreatorsRepository>()));
  sl.registerLazySingleton(() => GetCreatorDetailUseCase(sl<CreatorsRepository>()));
  sl.registerLazySingleton(() => GetCountriesUseCase(sl<CreatorsRepository>()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl<CreatorsRepository>()));
  sl.registerLazySingleton(() => CreateCreatorUseCase(sl<CreatorsRepository>()));
  sl.registerLazySingleton(() => UpdateCreatorUseCase(sl<CreatorsRepository>()));
  sl.registerLazySingleton(() => DeleteCreatorUseCase(sl<CreatorsRepository>()));
  sl.registerFactory(() => CreatorsBloc(
        getCreators:   sl<GetCreatorsUseCase>(),
        getCountries:  sl<GetCountriesUseCase>(),
        getCategories: sl<GetCategoriesUseCase>(),
      ));
  sl.registerFactory(() => CreatorDetailBloc(sl<GetCreatorDetailUseCase>()));
  sl.registerFactory(() => CreatorManageBloc(
        getCountries:   sl<GetCountriesUseCase>(),
        getCategories:  sl<GetCategoriesUseCase>(),
        createCreator:  sl<CreateCreatorUseCase>(),
        updateCreator:  sl<UpdateCreatorUseCase>(),
        deleteCreator:  sl<DeleteCreatorUseCase>(),
      ));

  // ─── Search ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(sl<DioClient>()));
  sl.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(sl<SearchRemoteDataSource>()));
  sl.registerLazySingleton(() => SearchCreatorsUseCase(sl<SearchRepository>()));
  sl.registerLazySingleton(() => SearchWorksUseCase(sl<SearchRepository>()));
  sl.registerFactory(() => SearchBloc(
        searchCreators: sl<SearchCreatorsUseCase>(),
        searchWorks:    sl<SearchWorksUseCase>(),
      ));

  // ─── Works ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WorksRemoteDataSource>(
      () => WorksRemoteDataSourceImpl(sl<DioClient>()));
  sl.registerLazySingleton<WorksRepository>(
      () => WorksRepositoryImpl(sl<WorksRemoteDataSource>()));
  sl.registerLazySingleton(() => GetWorkDetailUseCase(sl<WorksRepository>()));
  sl.registerFactory(() => WorkDetailBloc(sl<GetWorkDetailUseCase>()));

  // ─── Admin ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceImpl(sl<DioClient>()));
  sl.registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()));
  sl.registerLazySingleton(() => UploadWorkUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(
      () => GetPendingWorksUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(
      () => UpdateWorkStatusUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(
      () => GetDashboardStatsUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(() => PromoteUserUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetAdminWorksUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetAdminCreatorsUseCase(sl<AdminRepository>()));
  sl.registerFactory(() => UploadBloc(sl<UploadWorkUseCase>()));
  sl.registerFactory(() => ModerationBloc(
        getPendingWorks: sl<GetPendingWorksUseCase>(),
        updateStatus:    sl<UpdateWorkStatusUseCase>(),
      ));
  sl.registerFactory(() => DashboardBloc(sl<GetDashboardStatsUseCase>()));
  sl.registerFactory(() => UserManagementBloc(
        getUsers:    sl<GetUsersUseCase>(),
        promoteUser: sl<PromoteUserUseCase>(),
      ));
  sl.registerFactory(() => AdminDataBloc(
        getWorks:    sl<GetAdminWorksUseCase>(),
        getCreators: sl<GetAdminCreatorsUseCase>(),
      ));

  // ─── Profile ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl<DioClient>()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()));
  sl.registerLazySingleton(() => FetchProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(
      () => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerFactory(() => ProfileBloc(
        fetch:  sl<FetchProfileUseCase>(),
        update: sl<UpdateProfileUseCase>(),
      ));
}
