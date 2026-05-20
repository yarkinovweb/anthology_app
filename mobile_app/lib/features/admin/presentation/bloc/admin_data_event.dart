part of 'admin_data_bloc.dart';

abstract class AdminDataEvent extends Equatable {
  const AdminDataEvent();
  @override
  List<Object?> get props => [];
}

class FetchAdminDataEvent extends AdminDataEvent {
  const FetchAdminDataEvent();
}
