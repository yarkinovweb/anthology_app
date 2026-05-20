part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {
  const DashboardInitialState();
}

class DashboardLoadingState extends DashboardState {
  const DashboardLoadingState();
}

class DashboardLoadedState extends DashboardState {
  final DashboardStatsEntity stats;
  const DashboardLoadedState(this.stats);
  @override
  List<Object?> get props => [stats];
}

class DashboardErrorState extends DashboardState {
  final String message;
  const DashboardErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
