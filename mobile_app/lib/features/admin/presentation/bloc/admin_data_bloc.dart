import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../../domain/usecases/get_admin_creators_usecase.dart';
import '../../domain/usecases/get_admin_works_usecase.dart';

part 'admin_data_event.dart';
part 'admin_data_state.dart';

class AdminDataBloc extends Bloc<AdminDataEvent, AdminDataState> {
  final GetAdminWorksUseCase    _getWorks;
  final GetAdminCreatorsUseCase _getCreators;

  AdminDataBloc({
    required GetAdminWorksUseCase    getWorks,
    required GetAdminCreatorsUseCase getCreators,
  })  : _getWorks    = getWorks,
        _getCreators = getCreators,
        super(const AdminDataInitialState()) {
    on<FetchAdminDataEvent>(_onFetch);
  }

  Future<void> _onFetch(
      FetchAdminDataEvent event, Emitter<AdminDataState> emit) async {
    emit(const AdminDataLoadingState());

    final worksResult    = await _getWorks();
    final creatorsResult = await _getCreators();

    final works = worksResult.fold((_) => <WorkDetailEntity>[], (w) => w);
    final creators = creatorsResult.fold((_) => <CreatorEntity>[], (c) => c);
    final error = worksResult.isLeft()
        ? worksResult.fold((f) => f.message, (_) => null)
        : creatorsResult.fold((f) => f.message, (_) => null);

    if (error != null && works.isEmpty && creators.isEmpty) {
      emit(AdminDataErrorState(error));
    } else {
      emit(AdminDataLoadedState(works: works, creators: creators));
    }
  }
}
