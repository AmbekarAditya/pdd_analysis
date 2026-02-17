import '../../train_record/models/train_record.dart';

enum AlertType { critical, warning, info }

class DashboardAlert {
  final String message;
  final AlertType type;

  DashboardAlert({required this.message, required this.type});
}

class DashboardSummary {
  // Snapshot
  final int totalMovements;
  final int totalPddMinutes;
  final int avgPddMinutes;
  final int cleanAvgPddMinutes;
  final int excludedCount;

  // Analysis
  final Map<Department, double> departmentContribution; // Dept -> %
  final Map<Department, int> departmentDelay; // Dept -> Minutes
  final List<MapEntry<String, int>> topReasons; // Reason -> Count
  final List<TrendPoint> trend; // Date -> Avg PDD
  final List<DashboardAlert> alerts;

  DashboardSummary({
    required this.totalMovements,
    required this.totalPddMinutes,
    required this.avgPddMinutes,
    required this.cleanAvgPddMinutes,
    required this.excludedCount,
    required this.departmentContribution,
    required this.departmentDelay,
    required this.topReasons,
    required this.trend,
    required this.alerts,
  });
  
  // Empty state factory
  factory DashboardSummary.empty() => DashboardSummary(
    totalMovements: 0, 
    totalPddMinutes: 0, 
    avgPddMinutes: 0, 
    cleanAvgPddMinutes: 0, 
    excludedCount: 0, 
    departmentContribution: {}, 
    departmentDelay: {}, 
    topReasons: [], 
    trend: [], 
    alerts: []
  );
}

class TrendPoint {
  final DateTime date;
  final int avgPdd;
  
  TrendPoint(this.date, this.avgPdd);
}
