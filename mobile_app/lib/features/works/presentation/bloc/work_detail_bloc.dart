import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/work_detail_entity.dart';
import '../../domain/usecases/get_work_detail_usecase.dart';

part 'work_detail_event.dart';
part 'work_detail_state.dart';

class WorkDetailBloc extends Bloc<WorkDetailEvent, WorkDetailState> {
  final GetWorkDetailUseCase _getWorkDetail;

  WorkDetailBloc(this._getWorkDetail) : super(const WorkDetailInitial()) {
    on<LoadWorkDetailEvent>(_onLoad);
  }

  Future<void> _onLoad(
      LoadWorkDetailEvent event, Emitter<WorkDetailState> emit) async {
    emit(const WorkDetailLoading());
    final result = await _getWorkDetail(event.id);
    result.fold(
      (failure) => emit(WorkDetailError(failure.message)),
      (work)    => emit(WorkDetailLoaded(work)),
    );
  }
}
