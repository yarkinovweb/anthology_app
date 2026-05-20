part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class SearchCreatorsEvent extends SearchEvent {
  final String query;
  const SearchCreatorsEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchWorksEvent extends SearchEvent {
  final String query;
  const SearchWorksEvent(this.query);
  @override
  List<Object?> get props => [query];
}
