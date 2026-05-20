import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../creators/domain/entities/creator_entity.dart';
import '../../../works/domain/entities/work_detail_entity.dart';
import '../../domain/usecases/search_creators_usecase.dart';
import '../../domain/usecases/search_works_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchCreatorsUseCase _searchCreators;
  final SearchWorksUseCase _searchWorks;

  SearchBloc({
    required SearchCreatorsUseCase searchCreators,
    required SearchWorksUseCase searchWorks,
  })  : _searchCreators = searchCreators,
        _searchWorks = searchWorks,
        super(const SearchInitialState()) {
    on<SearchCreatorsEvent>(_onSearchCreators);
    on<SearchWorksEvent>(_onSearchWorks);
  }

  SearchSuccessState get _current =>
      state is SearchSuccessState
          ? state as SearchSuccessState
          : const SearchSuccessState();

  Future<void> _onSearchCreators(
    SearchCreatorsEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitialState());
      return;
    }
    emit(_current.copyWith(creatorsLoading: true));
    final result = await _searchCreators(event.query.trim());
    result.fold(
      (_) => emit(_current.copyWith(creatorsLoading: false)),
      (list) => emit(_current.copyWith(creators: list, creatorsLoading: false)),
    );
  }

  Future<void> _onSearchWorks(
    SearchWorksEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitialState());
      return;
    }
    emit(_current.copyWith(worksLoading: true));
    final result = await _searchWorks(event.query.trim());
    result.fold(
      (_) => emit(_current.copyWith(worksLoading: false)),
      (list) => emit(_current.copyWith(works: list, worksLoading: false)),
    );
  }
}
