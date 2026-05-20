part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();
}

class SearchInitialState extends SearchState {
  const SearchInitialState();
  @override
  List<Object?> get props => [];
}

class SearchSuccessState extends SearchState {
  final List<CreatorEntity> creators;
  final List<WorkDetailEntity> works;
  final bool creatorsLoading;
  final bool worksLoading;

  const SearchSuccessState({
    this.creators = const [],
    this.works = const [],
    this.creatorsLoading = false,
    this.worksLoading = false,
  });

  SearchSuccessState copyWith({
    List<CreatorEntity>? creators,
    List<WorkDetailEntity>? works,
    bool? creatorsLoading,
    bool? worksLoading,
  }) =>
      SearchSuccessState(
        creators: creators ?? this.creators,
        works: works ?? this.works,
        creatorsLoading: creatorsLoading ?? this.creatorsLoading,
        worksLoading: worksLoading ?? this.worksLoading,
      );

  @override
  List<Object?> get props => [creators, works, creatorsLoading, worksLoading];
}
