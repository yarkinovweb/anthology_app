import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final int totalUsers;
  final int approvedCreators;
  final int totalWorks;
  final int pendingWorks;

  const DashboardStatsEntity({
    required this.totalUsers,
    required this.approvedCreators,
    required this.totalWorks,
    required this.pendingWorks,
  });

  @override
  List<Object> get props => [totalUsers, approvedCreators, totalWorks, pendingWorks];
}
