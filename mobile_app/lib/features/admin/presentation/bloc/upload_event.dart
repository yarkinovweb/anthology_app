part of 'upload_bloc.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();
  @override
  List<Object?> get props => [];
}

class SubmitWorkEvent extends UploadEvent {
  final UploadWorkParams params;
  const SubmitWorkEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class ResetUploadEvent extends UploadEvent {
  const ResetUploadEvent();
}
