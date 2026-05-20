import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pending_work_entity.dart';
import '../../domain/usecases/get_pending_works_usecase.dart';
import '../../domain/usecases/update_work_status_usecase.dart';

part 'moderation_event.dart';
part 'moderation_state.dart';

class ModerationBloc extends Bloc<ModerationEvent, ModerationState> {
  final GetPendingWorksUseCase _getPendingWorks;
  final UpdateWorkStatusUseCase _updateStatus;

  ModerationBloc({
    required GetPendingWorksUseCase getPendingWorks,
    required UpdateWorkStatusUseCase updateStatus,
  })  : _getPendingWorks = getPendingWorks,
        _updateStatus    = updateStatus,
        super(const ModerationInitialState()) {
    on<FetchPendingWorksEvent>(_onFetch);
    on<ApproveWorkEvent>(_onApprove);
    on<RejectWorkEvent>(_onReject);
  }

  Future<void> _onFetch(
      FetchPendingWorksEvent event, Emitter<ModerationState> emit) async {
    emit(const ModerationLoadingState());
    final result = await _getPendingWorks();
    result.fold(
      (failure) => emit(ModerationErrorState(failure.message)),
      (works)   => emit(ModerationLoadedState(works: works)),
    );
  }

  Future<void> _onApprove(
      ApproveWorkEvent event, Emitter<ModerationState> emit) async {
    await _changeStatus(event.id, 'approved', emit);
  }

  Future<void> _onReject(
      RejectWorkEvent event, Emitter<ModerationState> emit) async {
    await _changeStatus(event.id, 'rejected', emit);
  }

  Future<void> _changeStatus(
      String id, String status, Emitter<ModerationState> emit) async {
    final current = state;
    if (current is! ModerationLoadedState) return;

    // Show per-item spinner
    emit(current.copyWith(
      processingIds: {...current.processingIds, id},
    ));

    final result =
        await _updateStatus(UpdateWorkStatusParams(id: id, status: status));

    if (result.isRight()) {
      // Optimistic removal
      final cur = state as ModerationLoadedState;
      emit(cur.copyWith(
        works:         cur.works.where((w) => w.id != id).toList(),
        processingIds: Set<String>.from(cur.processingIds)..remove(id),
      ));
    } else {
      // Revert processing flag, then re-fetch to restore truth
      final cur = state;
      if (cur is ModerationLoadedState) {
        emit(cur.copyWith(
          processingIds: Set<String>.from(cur.processingIds)..remove(id),
        ));
      }
      final refreshResult = await _getPendingWorks();
      refreshResult.fold(
        (f) => emit(ModerationErrorState(f.message)),
        (works) => emit(ModerationLoadedState(works: works)),
      );
    }
  }
}
