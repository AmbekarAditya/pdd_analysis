import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../train_record/models/train_record.dart';
import '../../train_record/providers/record_providers.dart';
import '../models/analysis_period.dart';
import '../models/dashboard_summary.dart';

// Period Controller
class DashboardPeriodController extends Notifier<AnalysisPeriod> {
  @override
  AnalysisPeriod build() {
    // Default: Today (as requested)
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return AnalysisPeriod(startDate: start, endDate: end, preset: PeriodPreset.today);
  }

  void setPreset(PeriodPreset preset) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (preset) {
      case PeriodPreset.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case PeriodPreset.last7Days:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        break;
      case PeriodPreset.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case PeriodPreset.custom:
        start = state.startDate;
        end = state.endDate;
        break;
    }
    state = AnalysisPeriod(startDate: start, endDate: end, preset: preset);
  }

  void setCustomRange(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    state = AnalysisPeriod(startDate: s, endDate: e, preset: PeriodPreset.custom);
  }
}

final analysisPeriodProvider = NotifierProvider<DashboardPeriodController, AnalysisPeriod>(DashboardPeriodController.new);

// Dashboard Summary Provider
final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final recordsAsync = ref.watch(trainRecordsStreamProvider);
  final period = ref.watch(analysisPeriodProvider);

  return recordsAsync.whenData((allRecords) {
    // 1. Filter Records by Selected Period
    final records = allRecords.where((r) {
      return r.date.isAfter(period.startDate.subtract(const Duration(seconds: 1))) && 
             r.date.isBefore(period.endDate.add(const Duration(seconds: 1)));
    }).toList();

    if (records.isEmpty) return DashboardSummary.empty();

    // 2. Calculate Snapshots
    int totalPdd = 0;
    int avoidablePddSum = 0;
    int avoidableCount = 0;
    int unavoidableCount = 0;
    
    // Dept & Reason Maps
    final deptDelay = <Department, int>{};
    final reasonFreq = <String, int>{};

    for (var r in records) {
      totalPdd += r.pddMinutes;
      
      if (r.isExcluded) {
        unavoidableCount++;
      } else {
        avoidablePddSum += r.pddMinutes;
        avoidableCount++;
      }

      // Dept (if valid)
      if (r.primaryDepartment != Department.unknown) {
        deptDelay[r.primaryDepartment] = (deptDelay[r.primaryDepartment] ?? 0) + r.pddMinutes;
      }

      // Reason
      reasonFreq[r.subReason] = (reasonFreq[r.subReason] ?? 0) + 1;
    }

    final avgPdd = (totalPdd / records.length).round();
    final avoidableAvgPdd = avoidableCount > 0 ? (avoidablePddSum / avoidableCount).round() : 0;

    // 3. Dept Contribution
    final deptContrib = <Department, double>{};
    if (totalPdd > 0) {
      deptDelay.forEach((k, v) {
        deptContrib[k] = (v / totalPdd) * 100;
      });
    }

    // 4. Top Reasons
    final sortedReasons = reasonFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topReasons = sortedReasons.take(5).toList();

    // 5. Trend (Daily Avg for the filtered period)
    // If period is Today, maybe show last 7 days from DB? 
    // Requirement: "SECTION 3 — 7-DAY TREND... Display line chart of Avg PDD for last 7 days."
    // If we only filter `records` by `Today`, we won't have 7 days data.
    // So we need to fetch history specifically for Trend if period is small.
    // Let's grab last 7 days data from `allRecords` separate for trend if needed.
    
    List<TrendPoint> trend = [];
    final trendStart = period.preset == PeriodPreset.today 
        ? DateTime.now().subtract(const Duration(days: 6)) // Last 7 days inclusive
        : period.startDate;
        
    final trendEnd = period.endDate;
    
    // Aggregate daily for trend
    final trendMap = <int, List<int>>{}; // DayEpoch -> List of PDD
    // Populate keys for full range
    for (int i = 0; i <= trendEnd.difference(trendStart).inDays; i++) {
      final d = trendStart.add(Duration(days: i));
      final k = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      trendMap[k] = [];
    }
    
    // Fill with ALL records in trend range (not just selected period records)
    for (var r in allRecords) {
       if (r.date.isAfter(trendStart.subtract(const Duration(seconds: 1))) && 
           r.date.isBefore(trendEnd.add(const Duration(seconds: 1)))) {
         final k = DateTime(r.date.year, r.date.month, r.date.day).millisecondsSinceEpoch;
         if (trendMap.containsKey(k)) {
           trendMap[k]!.add(r.pddMinutes);
         }
       }
    }
    
    final sortedTrendKeys = trendMap.keys.toList()..sort();
    trend = sortedTrendKeys.map((k) {
      final pdds = trendMap[k]!;
      final avg = pdds.isNotEmpty ? (pdds.reduce((a, b) => a + b) / pdds.length).round() : 0;
      return TrendPoint(DateTime.fromMillisecondsSinceEpoch(k), avg);
    }).toList();


    // 6. Alerts
    final alerts = <DashboardAlert>[];

    // Alert: Any PDD > 120
    final extremeDelays = records.where((r) => r.pddMinutes > 120).length;
    if (extremeDelays > 0) {
      alerts.add(DashboardAlert(
        message: '$extremeDelays trains with PDD > 2 hours', 
        type: AlertType.critical
      ));
    }

    // Alert: Avoidable Avg > 30
    if (avoidableAvgPdd > 30) {
       alerts.add(DashboardAlert(
        message: 'Avoidable Avg PDD is high ($avoidableAvgPdd min)', 
        type: AlertType.warning
      ));
    }

    // Alert: Same subReason >= 3 times
    for (var e in reasonFreq.entries) {
      if (e.value >= 3) {
        alerts.add(DashboardAlert(
          message: 'Repeated Issue: "${e.key}" (${e.value} times)', 
          type: AlertType.warning
        ));
      }
    }
    
    // Alert: Top Dept Count > 70% (Controllable usually means Dept caused, simplified here as Department Share > 70%)
    if (deptContrib.isNotEmpty) {
       final topDeptEntry = deptContrib.entries.reduce((a, b) => a.value > b.value ? a : b);
       if (topDeptEntry.value > 70) {
         alerts.add(DashboardAlert(
           message: '${topDeptEntry.key.label} contributing ${topDeptEntry.value.toStringAsFixed(0)}% of delays',
           type: AlertType.info
         ));
       }
    }


    return DashboardSummary(
      totalMovements: records.length,
      totalPddMinutes: totalPdd,
      avgPddMinutes: avgPdd,
      avoidableAvgPddMinutes: avoidableAvgPdd,
      unavoidableCount: unavoidableCount,
      departmentContribution: deptContrib,
      departmentDelay: deptDelay,
      topReasons: topReasons,
      trend: trend,
      alerts: alerts,
    );
  });
});
