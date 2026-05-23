import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase     _login;
  final RegisterUseCase  _register;
  final CheckAuthUseCase _checkAuth;
  final LogoutUseCase    _logout;

  AuthBloc({
    required LoginUseCase     login,
    required RegisterUseCase  register,
    required CheckAuthUseCase checkAuth,
    required LogoutUseCase    logout,
  })  : _login     = login,
        _register  = register,
        _checkAuth = checkAuth,
        _logout    = logout,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // Splash animatsiyasi ko'rinishi uchun minimal kutish vaqti
    final authFuture = _checkAuth();
    await Future.wait([authFuture, Future.delayed(const Duration(milliseconds: 2000))]);
    final result = await authFuture;
    result.fold(
      (_) => emit(const Unauthenticated()),
      (user) =>
          user != null ? emit(Authenticated(user)) : emit(const Unauthenticated()),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user)    => emit(Authenticated(user)),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _register(
      RegisterParams(name: event.name, email: event.email, password: event.password, role: event.role),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user)    => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const Unauthenticated());
  }
}
