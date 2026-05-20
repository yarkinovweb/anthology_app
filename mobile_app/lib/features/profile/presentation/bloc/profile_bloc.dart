import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/update_profile_params.dart';
import '../../domain/usecases/fetch_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FetchProfileUseCase  _fetch;
  final UpdateProfileUseCase _update;

  ProfileBloc({
    required FetchProfileUseCase  fetch,
    required UpdateProfileUseCase update,
  })  : _fetch  = fetch,
        _update = update,
        super(const ProfileInitialState()) {
    on<FetchProfileEvent>(_onFetch);
    on<UpdateProfileEvent>(_onUpdate);
  }

  Future<void> _onFetch(
    FetchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    final result = await _fetch();
    result.fold(
      (failure) => emit(ProfileErrorState(failure.message)),
      (user)    => emit(ProfileLoadedState(user)),
    );
  }

  Future<void> _onUpdate(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    final currentUser = current is ProfileLoadedState
        ? current.user
        : current is ProfileUpdatingState
            ? current.user
            : null;

    if (currentUser == null) return;

    emit(ProfileUpdatingState(currentUser));

    final result = await _update(
      UpdateProfileParams(
        name:     event.name,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(ProfileErrorState(failure.message)),
      (updated) {
        emit(ProfileUpdateSuccessState(updated));
        emit(ProfileLoadedState(updated));
      },
    );
  }
}
