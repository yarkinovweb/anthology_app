import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/entities/creator_form_params.dart';
import '../../domain/usecases/create_creator_usecase.dart';
import '../../domain/usecases/delete_creator_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_countries_usecase.dart';
import '../../domain/usecases/update_creator_usecase.dart';

part 'creator_manage_event.dart';
part 'creator_manage_state.dart';

class CreatorManageBloc extends Bloc<CreatorManageEvent, CreatorManageState> {
  final GetCountriesUseCase _getCountries;
  final GetCategoriesUseCase _getCategories;
  final CreateCreatorUseCase _createCreator;
  final UpdateCreatorUseCase _updateCreator;
  final DeleteCreatorUseCase _deleteCreator;

  CreatorManageBloc({
    required GetCountriesUseCase getCountries,
    required GetCategoriesUseCase getCategories,
    required CreateCreatorUseCase createCreator,
    required UpdateCreatorUseCase updateCreator,
    required DeleteCreatorUseCase deleteCreator,
  })  : _getCountries = getCountries,
        _getCategories = getCategories,
        _createCreator = createCreator,
        _updateCreator = updateCreator,
        _deleteCreator = deleteCreator,
        super(const CreatorManageInitial()) {
    on<LoadCreatorFormDataEvent>(_onLoadFormData);
    on<SaveCreatorEvent>(_onSave);
    on<DeleteCreatorEvent>(_onDelete);
  }

  Future<void> _onLoadFormData(
    LoadCreatorFormDataEvent event,
    Emitter<CreatorManageState> emit,
  ) async {
    emit(const CreatorManageFormLoading());
    final countriesResult = await _getCountries();
    final categoriesResult = await _getCategories();

    final countries = countriesResult.fold((_) => <CountryEntity>[], (v) => v);
    final categories = categoriesResult.fold((_) => <CategoryEntity>[], (v) => v);

    emit(CreatorManageFormReady(
      countries: countries,
      categories: categories,
      existing: event.existing,
    ));
  }

  Future<void> _onSave(
    SaveCreatorEvent event,
    Emitter<CreatorManageState> emit,
  ) async {
    emit(const CreatorManageSaving());
    if (event.editId != null) {
      final result = await _updateCreator(event.editId!, event.params);
      result.fold(
        (f) => emit(CreatorManageError(f.message)),
        (creator) => emit(CreatorManageSaveSuccess(creator, isNew: false)),
      );
    } else {
      final result = await _createCreator(event.params);
      result.fold(
        (f) => emit(CreatorManageError(f.message)),
        (creator) => emit(CreatorManageSaveSuccess(creator, isNew: true)),
      );
    }
  }

  Future<void> _onDelete(
    DeleteCreatorEvent event,
    Emitter<CreatorManageState> emit,
  ) async {
    emit(const CreatorManageSaving());
    final result = await _deleteCreator(event.creatorId);
    result.fold(
      (f) => emit(CreatorManageError(f.message)),
      (_) => emit(const CreatorManageDeleteSuccess()),
    );
  }
}
