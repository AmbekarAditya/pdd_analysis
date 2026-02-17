import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_summary.dart';
import '../providers/record_providers.dart';

// Selected Date Notifier
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
  void nextDay() => state = state.add(const Duration(days: 1));
  void previousDay() => state = state.subtract(const Duration(days: 1));
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

// Daily Summary Provider
final dailySummaryProvider = Provider<AsyncValue<DailySummary>>((ref) {
  final allRecordsAsync = ref.watch(trainRecordsStreamProvider);
  final date = ref.watch(selectedDateProvider);

  return allRecordsAsync.whenData((records) {
    final dailyRecords = records.where((r) =>
      r.date.year == date.year &&
      r.date.month == date.month &&
      r.date.day == date.day
    ).toList();
    
    // Sort by PDD descending for "Expandable Train Breakdown List" (implicit requirement usually, or by time?)
    // Let's sort by Departure Time (Ascending) or PDD (Descending)?
    // Operational logs usually sorted by time.
    // Let's sort by Actual Departure.
    dailyRecords.sort((a, b) {
       // Sort logic if needed, otherwise existing list order (recency)
       return b.date.compareTo(a.date);
    });

    return DailySummary.fromRecords(date, dailyRecords);
  });
});
