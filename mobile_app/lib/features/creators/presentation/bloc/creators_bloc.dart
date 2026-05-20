import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/entities/creator_filters.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_countries_usecase.dart';
import '../../domain/usecases/get_creators_usecase.dart';

part 'creators_event.dart';
part 'creators_state.dart';

class CreatorsBloc extends Bloc<CreatorsEvent, CreatorsState> {
  final GetCreatorsUseCase   _getCreators;
  final GetCountriesUseCase  _getCountries;
  final GetCategoriesUseCase _getCategories;

  CreatorsBloc({
    required GetCreatorsUseCase   getCreators,
    required GetCountriesUseCase  getCountries,
    required GetCategoriesUseCase getCategories,
  })  : _getCreators   = getCreators,
        _getCountries  = getCountries,
        _getCategories = getCategories,
        super(const CreatorsInitial()) {
    on<FetchCreatorsEvent>(_onFetch);
    on<SearchCreatorsEvent>(_onSearch);
  }

  Future<void> _onFetch(
    FetchCreatorsEvent event,
    Emitter<CreatorsState> emit,
  ) async {
    emit(const CreatorsLoading());

    // country + category: birinchi yuklashda olinadi, keyingisida cache ishlatiladi
    List<CountryEntity>  countries;
    List<CategoryEntity> categories;

    final prev = state;
    if (prev is CreatorsLoaded) {
      countries  = prev.countries;
      categories = prev.categories;
    } else {
      final results = await Future.wait([_getCountries(), _getCategories()]);
      countries  = results[0].fold((_) => [], (v) => v as List<CountryEntity>);
      categories = results[1].fold((_) => [], (v) => v as List<CategoryEntity>);
    }

    final result = await _getCreators(event.filters);
    result.fold(
      (failure) => emit(CreatorsError(failure.message)),
      (creators) => emit(CreatorsLoaded(
        creators:      creators,
        countries:     countries,
        categories:    categories,
        activeFilters: event.filters,
      )),
    );
  }

  Future<void> _onSearch(
    SearchCreatorsEvent event,
    Emitter<CreatorsState> emit,
  ) async {
    final prev = state;
    final currentFilters = prev is CreatorsLoaded
        ? prev.activeFilters
        : const CreatorFilters();

    final newFilters = event.query.isEmpty
        ? currentFilters.copyWith(clearSearch: true)
        : currentFilters.copyWith(search: event.query);

    add(FetchCreatorsEvent(filters: newFilters));
  }
}
