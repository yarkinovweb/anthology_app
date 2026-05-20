part of 'admin_data_bloc.dart';

abstract class AdminDataState extends Equatable {
  const AdminDataState();
  @override
  List<Object?> get props => [];
}

class AdminDataInitialState extends AdminDataState {
  const AdminDataInitialState();
}

class AdminDataLoadingState extends AdminDataState {
  const AdminDataLoadingState();
}

class AdminDataLoadedState extends AdminDataState {
  final List<WorkDetailEntity>  works;
  final List<CreatorEntity>     creators;

  const AdminDataLoadedState({
    required this.works,
    required this.creators,
  });

  @override
  List<Object?> get props => [works, creators];
}

class AdminDataErrorState extends AdminDataState {
  final String message;
  const AdminDataErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
