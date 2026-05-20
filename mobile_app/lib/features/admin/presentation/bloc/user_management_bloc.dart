import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_list_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/promote_user_usecase.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  final GetUsersUseCase    _getUsers;
  final PromoteUserUseCase _promoteUser;

  UserManagementBloc({
    required GetUsersUseCase    getUsers,
    required PromoteUserUseCase promoteUser,
  })  : _getUsers    = getUsers,
        _promoteUser = promoteUser,
        super(const UserManagementInitialState()) {
    on<FetchUsersEvent>(_onFetch);
    on<PromoteUserEvent>(_onPromote);
  }

  Future<void> _onFetch(
      FetchUsersEvent event, Emitter<UserManagementState> emit) async {
    emit(const UserManagementLoadingState());
    final result = await _getUsers();
    result.fold(
      (f) => emit(UserManagementErrorState(f.message)),
      (users) => emit(UserManagementLoadedState(users: users)),
    );
  }

  Future<void> _onPromote(
      PromoteUserEvent event, Emitter<UserManagementState> emit) async {
    final current = state;
    if (current is! UserManagementLoadedState) return;

    emit(current.copyWith(
      promotingIds: {...current.promotingIds, event.userId},
    ));

    final result = await _promoteUser(event.userId);

    final cur = state as UserManagementLoadedState;
    if (result.isRight()) {
      final updated = result.getOrElse(() => throw StateError('unreachable'));
      emit(cur.copyWith(
        users: cur.users
            .map((u) => u.id == updated.id ? updated : u)
            .toList(),
        promotingIds: Set<String>.from(cur.promotingIds)..remove(event.userId),
      ));
    } else {
      emit(cur.copyWith(
        promotingIds: Set<String>.from(cur.promotingIds)..remove(event.userId),
      ));
    }
  }
}
