part of 'creators_bloc.dart';

abstract class CreatorsState extends Equatable {
  const CreatorsState();
  @override
  List<Object?> get props => [];
}

class CreatorsInitial extends CreatorsState {
  const CreatorsInitial();
}

class CreatorsLoading extends CreatorsState {
  const CreatorsLoading();
}

class CreatorsLoaded extends CreatorsState {
  final List<CreatorEntity>  creators;
  final List<CountryEntity>  countries;
  final List<CategoryEntity> categories;
  final CreatorFilters       activeFilters;

  const CreatorsLoaded({
    required this.creators,
    required this.countries,
    required this.categories,
    required this.activeFilters,
  });

  @override
  List<Object?> get props => [creators, activeFilters];
}

class CreatorsError extends CreatorsState {
  final String message;
  const CreatorsError(this.message);

  @override
  List<Object?> get props => [message];
}
