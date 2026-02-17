import 'train_record.dart';

class DailySummary {
  final DateTime date;
  final int totalMovements;
  final int totalPddMinutes;
  final int averagePddMinutes;
  final int cleanAveragePddMinutes;
  final int excludedCount;
  final Map<Department, int> departmentDelayMinutes;
  final Map<Department, double> departmentContributionPercent;
  final List<MapEntry<String, int>> topSubReasons; // Reason -> Frequency or Delay? Spec says "By frequency"
  final List<TrainRecord> records;

  DailySummary({
    required this.date,
    required this.totalMovements,
    required this.totalPddMinutes,
    required this.averagePddMinutes,
    required this.cleanAveragePddMinutes,
    required this.excludedCount,
    required this.departmentDelayMinutes,
    required this.departmentContributionPercent,
    required this.topSubReasons,
    required this.records,
  });

  factory DailySummary.fromRecords(DateTime date, List<TrainRecord> dailyRecords) {
    if (dailyRecords.isEmpty) {
      return DailySummary(
        date: date,
        totalMovements: 0,
        totalPddMinutes: 0,
        averagePddMinutes: 0,
        cleanAveragePddMinutes: 0,
        excludedCount: 0,
        departmentDelayMinutes: {},
        departmentContributionPercent: {},
        topSubReasons: [],
        records: [],
      );
    }

    int totalPdd = 0;
    int cleanPddSum = 0;
    int cleanCount = 0;
    int excluded = 0;
    
    final Map<Department, int> deptDelay = {};
    final Map<String, int> subReasonFreq = {};

    for (var r in dailyRecords) {
      final pdd = r.pddMinutes;
      totalPdd += pdd;

      if (r.isExcluded) {
        excluded++;
      } else {
        cleanPddSum += pdd;
        cleanCount++;
      }

      // Dept Contribution (Delay based)
      // "Department Contribution Section - Show total delay per department" (implied PDD contribution)
      // Since record attribute delay to a department, we assign the full PDD of the record to that department?
      // Or is it pure delay breakdown (Loco, C&W)?
      // "Primary Department" implies attribution. So we attribute the PDD to that department.
      // If primaryDepartment is set.
      if (r.primaryDepartment != Department.unknown) {
         deptDelay[r.primaryDepartment] = (deptDelay[r.primaryDepartment] ?? 0) + pdd;
      }

      // SubReasons
      subReasonFreq[r.subReason] = (subReasonFreq[r.subReason] ?? 0) + 1;
    }

    // Calculations
    final avgPdd = (totalPdd / dailyRecords.length).round();
    final cleanAvg = cleanCount > 0 ? (cleanPddSum / cleanCount).round() : 0;
    
    // Percentages
    final Map<Department, double> deptPercent = {};
    if (totalPdd > 0) {
      deptDelay.forEach((k, v) {
        deptPercent[k] = (v / totalPdd) * 100;
      });
    }

    // Sort Top 5 Reasons
    final sortedReasons = subReasonFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sortedReasons.take(5).toList();

    return DailySummary(
      date: date,
      totalMovements: dailyRecords.length,
      totalPddMinutes: totalPdd,
      averagePddMinutes: avgPdd,
      cleanAveragePddMinutes: cleanAvg,
      excludedCount: excluded,
      departmentDelayMinutes: deptDelay,
      departmentContributionPercent: deptPercent,
      topSubReasons: top5,
      records: dailyRecords,
    );
  }
}
