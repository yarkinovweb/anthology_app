part of 'creators_bloc.dart';

abstract class CreatorsEvent extends Equatable {
  const CreatorsEvent();
  @override
  List<Object?> get props => [];
}

// Sahifa ochilganda: country + category + creators birga yuklanadi
class FetchCreatorsEvent extends CreatorsEvent {
  final CreatorFilters filters;
  const FetchCreatorsEvent({this.filters = const CreatorFilters()});

  @override
  List<Object?> get props => [filters];
}

// Qidiruv maydoni o'zgarganda (debounce UI da)
class SearchCreatorsEvent extends CreatorsEvent {
  final String query;
  const SearchCreatorsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
