import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/analysis_period.dart';

class DashboardController extends Notifier<AnalysisPeriod> {
  @override
  AnalysisPeriod build() {
    // Default: This Month (1st to Today)
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59); // End of today
    
    return AnalysisPeriod(startDate: start, endDate: end, preset: PeriodPreset.thisMonth);
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
        // Keep current custom range or default to today if switching to custom without range?
        // Usually set via setCustomRange logic.
        // If just switching preset tag, maybe keep current dates?
        // But UI usually calls setCustomRange directly.
        // Let's assume this is only called for the defined presets.
        start = state.startDate;
        end = state.endDate;
        break;
    }

    state = AnalysisPeriod(startDate: start, endDate: end, preset: preset);
  }

  void setCustomRange(DateTime start, DateTime end) {
    // Normalize start to beginning of day, end to end of day
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    state = AnalysisPeriod(startDate: s, endDate: e, preset: PeriodPreset.custom);
  }
}

final analysisPeriodProvider = NotifierProvider<DashboardController, AnalysisPeriod>(DashboardController.new);
