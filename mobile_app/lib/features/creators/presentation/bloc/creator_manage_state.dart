part of 'creator_manage_bloc.dart';

abstract class CreatorManageState extends Equatable {
  const CreatorManageState();
  @override
  List<Object?> get props => [];
}

class CreatorManageInitial extends CreatorManageState {
  const CreatorManageInitial();
}

class CreatorManageFormLoading extends CreatorManageState {
  const CreatorManageFormLoading();
}

class CreatorManageFormReady extends CreatorManageState {
  final List<CountryEntity> countries;
  final List<CategoryEntity> categories;
  final CreatorEntity? existing;

  const CreatorManageFormReady({
    required this.countries,
    required this.categories,
    this.existing,
  });

  @override
  List<Object?> get props => [countries, categories, existing];
}

class CreatorManageSaving extends CreatorManageState {
  const CreatorManageSaving();
}

class CreatorManageSaveSuccess extends CreatorManageState {
  final CreatorEntity creator;
  final bool isNew;
  const CreatorManageSaveSuccess(this.creator, {required this.isNew});
  @override
  List<Object?> get props => [creator, isNew];
}

class CreatorManageDeleteSuccess extends CreatorManageState {
  const CreatorManageDeleteSuccess();
}

class CreatorManageError extends CreatorManageState {
  final String message;
  const CreatorManageError(this.message);
  @override
  List<Object?> get props => [message];
}
