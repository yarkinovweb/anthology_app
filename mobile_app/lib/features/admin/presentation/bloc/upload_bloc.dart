import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/upload_work_params.dart';
import '../../domain/usecases/upload_work_usecase.dart';
import '../../../../core/errors/failures.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadWorkUseCase _uploadWork;

  UploadBloc(this._uploadWork) : super(const UploadInitialState()) {
    on<SubmitWorkEvent>(_onSubmit);
    on<ResetUploadEvent>(_onReset);
  }

  Future<void> _onSubmit(
      SubmitWorkEvent event, Emitter<UploadState> emit) async {
    emit(const UploadInProgressState(0));
    try {
      await emit.forEach<double>(
        _uploadWork(event.params),
        onData: (progress) => UploadInProgressState(progress),
      );
      emit(const UploadSuccessState());
    } on Failure catch (f) {
      emit(UploadErrorState(f.message));
    } catch (e) {
      emit(UploadErrorState(e.toString()));
    }
  }

  void _onReset(ResetUploadEvent event, Emitter<UploadState> emit) {
    emit(const UploadInitialState());
  }
}
