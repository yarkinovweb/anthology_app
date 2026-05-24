import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/usecases/get_creator_detail_usecase.dart';

part 'creator_detail_event.dart';
part 'creator_detail_state.dart';

class CreatorDetailBloc extends Bloc<CreatorDetailEvent, CreatorDetailState> {
  final GetCreatorDetailUseCase _getDetail;

  CreatorDetailBloc(this._getDetail) : super(const CreatorDetailInitial()) {
    on<LoadCreatorDetailEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadCreatorDetailEvent event,
    Emitter<CreatorDetailState> emit,
  ) async {
    debugPrint('[CreatorDetailBloc] loading id=${event.creatorId}');
    emit(const CreatorDetailLoading());
    final result = await _getDetail(event.creatorId);
    result.fold(
      (failure) {
        debugPrint('[CreatorDetailBloc] error: ${failure.message}');
        emit(CreatorDetailError(failure.message));
      },
      (creator) {
        debugPrint('[CreatorDetailBloc] loaded: ${creator.name}, works=${creator.works.length}');
        emit(CreatorDetailLoaded(creator));
      },
    );
  }
}
