import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalUsers,
    required super.approvedCreators,
    required super.totalWorks,
    required super.pendingWorks,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      DashboardStatsModel(
        totalUsers:       _parseInt(json['total_users']),
        approvedCreators: _parseInt(json['approved_creators']),
        totalWorks:       _parseInt(json['total_works']),
        pendingWorks:     _parseInt(json['pending_works']),
      );

  static int _parseInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;
}
