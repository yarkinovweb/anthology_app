part of 'upload_bloc.dart';

abstract class UploadState extends Equatable {
  const UploadState();
  @override
  List<Object?> get props => [];
}

class UploadInitialState extends UploadState {
  const UploadInitialState();
}

class UploadInProgressState extends UploadState {
  final double progress; // 0.0 – 1.0
  const UploadInProgressState(this.progress);
  @override
  List<Object?> get props => [progress];
}

class UploadSuccessState extends UploadState {
  const UploadSuccessState();
}

class UploadErrorState extends UploadState {
  final String message;
  const UploadErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
