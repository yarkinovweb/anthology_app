part of 'creator_manage_bloc.dart';

abstract class CreatorManageEvent extends Equatable {
  const CreatorManageEvent();
  @override
  List<Object?> get props => [];
}

class LoadCreatorFormDataEvent extends CreatorManageEvent {
  // Load countries and categories for dropdowns
  // Optionally pre-fill with existing creator for edit mode
  final CreatorEntity? existing;
  const LoadCreatorFormDataEvent({this.existing});
  @override
  List<Object?> get props => [existing];
}

class SaveCreatorEvent extends CreatorManageEvent {
  final CreatorFormParams params;
  final String? editId; // null = create, non-null = update
  const SaveCreatorEvent(this.params, {this.editId});
  @override
  List<Object?> get props => [params, editId];
}

class DeleteCreatorEvent extends CreatorManageEvent {
  final String creatorId;
  const DeleteCreatorEvent(this.creatorId);
  @override
  List<Object?> get props => [creatorId];
}
