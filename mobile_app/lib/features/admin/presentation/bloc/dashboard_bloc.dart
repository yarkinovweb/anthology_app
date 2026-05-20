import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase _getStats;

  DashboardBloc(this._getStats) : super(const DashboardInitialState()) {
    on<FetchDashboardStatsEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchDashboardStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadingState());
    final result = await _getStats();
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (stats)   => emit(DashboardLoadedState(stats)),
    );
  }
}
