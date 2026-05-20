part of 'work_detail_bloc.dart';

abstract class WorkDetailEvent extends Equatable {
  const WorkDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkDetailEvent extends WorkDetailEvent {
  final String id;
  const LoadWorkDetailEvent(this.id);
  @override
  List<Object?> get props => [id];
}
