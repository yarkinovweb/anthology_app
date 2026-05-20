part of 'work_detail_bloc.dart';

abstract class WorkDetailState extends Equatable {
  const WorkDetailState();
  @override
  List<Object?> get props => [];
}

class WorkDetailInitial extends WorkDetailState {
  const WorkDetailInitial();
}

class WorkDetailLoading extends WorkDetailState {
  const WorkDetailLoading();
}

class WorkDetailLoaded extends WorkDetailState {
  final WorkDetailEntity work;
  const WorkDetailLoaded(this.work);
  @override
  List<Object?> get props => [work];
}

class WorkDetailError extends WorkDetailState {
  final String message;
  const WorkDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
