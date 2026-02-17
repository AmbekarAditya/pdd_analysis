import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/record_filter_state.dart';
import '../models/train_record.dart';
import '../providers/record_providers.dart';

// Notifier for the Filter State
class TrainRecordsController extends Notifier<RecordFilterState> {
  @override
  RecordFilterState build() {
    return const RecordFilterState();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void toggleDateFilter(DateFilterPreset preset) {
    // If clicking the same preset, toggle off to 'all' (unless it's 'all' already)
    // Actually typically chips: if "Today" is active and clicked, it might turn off.
    // If "Today" is inactive and clicked, it becomes active.
    // Since we only allow ONE date filter at a time (radio behavior usually for time ranges), 
    // let's stick to simple replacement.
    if (state.dateFilter == preset && preset != DateFilterPreset.all) {
      state = state.copyWith(dateFilter: DateFilterPreset.all);
    } else {
      state = state.copyWith(dateFilter: preset);
    }
  }

  void toggleDepartment(String department) {
    final current = List<String>.from(state.selectedDepartments);
    if (current.contains(department)) {
      current.remove(department);
    } else {
      current.add(department);
    }
    state = state.copyWith(selectedDepartments: current);
  }

  void toggleStatusFilter(RecordStatusFilter filter) {
    final current = List<RecordStatusFilter>.from(state.selectedStatusFilters);
    if (current.contains(filter)) {
      current.remove(filter);
    } else {
      current.add(filter);
    }
    state = state.copyWith(selectedStatusFilters: current);
  }

  void resetFilters() {
    state = const RecordFilterState();
  }
}

final trainRecordsFilterProvider =
    NotifierProvider<TrainRecordsController, RecordFilterState>(TrainRecordsController.new);

// Computed Provider: Filtered Records
final filteredRecordsProvider = Provider<List<TrainRecord>>((ref) {
  final allRecordsAsync = ref.watch(trainRecordsStreamProvider);
  final filterState = ref.watch(trainRecordsFilterProvider);

  return allRecordsAsync.maybeWhen(
    data: (records) {
      return records.where((record) {
        // 1. Date Filter
        final now = DateTime.now();
        final recordDate = record.date;
        bool dateMatch = true;
        
        // Normalize dates to remove time component for comparison if needed, 
        // but record.date is usually DateTime (start of day?) or includes time.
        // Let's assume comparisons based on day.
        final today = DateTime(now.year, now.month, now.day);
        final rDate = DateTime(recordDate.year, recordDate.month, recordDate.day);
        
        switch (filterState.dateFilter) {
          case DateFilterPreset.today:
             dateMatch = rDate.isAtSameMomentAs(today);
             break;
          case DateFilterPreset.last7Days:
             final sevenDaysAgo = today.subtract(const Duration(days: 7));
             dateMatch = rDate.isAfter(sevenDaysAgo) || rDate.isAtSameMomentAs(sevenDaysAgo);
             break;
          case DateFilterPreset.thisMonth:
             dateMatch = rDate.year == today.year && rDate.month == today.month;
             break;
          case DateFilterPreset.all:
          default:
             dateMatch = true;
             break;
        }
        if (!dateMatch) return false;

        // 2. Department Filter (OR logic: if record has Dep A AND Dep A is selected -> keep)
        // If selection is empty, show all.
        if (filterState.selectedDepartments.isNotEmpty) {
          if (record.primaryDepartment == null ||
              !filterState.selectedDepartments.contains(record.primaryDepartment)) {
            return false;
          }
        }

        // 3. Status Filters (Mixed logic)
        // Separate status filters into sets
        final statusFilters = filterState.selectedStatusFilters;
        if (statusFilters.isNotEmpty) {
          bool keep = true;
          
          // A. Delay Magnitude (High vs Zero) - OR logic if both present?
          // "High Delay" (>30), "Zero Delay" (==0).
          // If User selects "High Delay", we filter for >30.
          // If User also selects "Zero Delay", we filter for (>30 OR ==0).
          final hasHighDelay = statusFilters.contains(RecordStatusFilter.highDelay);
          final hasZeroDelay = statusFilters.contains(RecordStatusFilter.zeroDelay);
          
          if (hasHighDelay || hasZeroDelay) {
             final minutes = _parsePddMinutes(record.pdd);
             bool matchesDelay = false;
             if (hasHighDelay && minutes > 30) matchesDelay = true;
             if (hasZeroDelay && minutes == 0) matchesDelay = true;
             
             if (!matchesDelay) return false;
          }

          // B. Exclusion (Excluded vs Non-Excluded) - OR logic logic if both present?
          // If User selects "Excluded", keep excluded.
          // If User selects "Non-Excluded", keep non-excluded.
          // If both, keep both (effectively no filter on exclusion).
          final hasExcluded = statusFilters.contains(RecordStatusFilter.excluded);
          final hasNonExcluded = statusFilters.contains(RecordStatusFilter.nonExcluded);
          
          if (hasExcluded && !hasNonExcluded) {
            if (!record.isExcluded) return false;
          } else if (hasNonExcluded && !hasExcluded) {
            if (record.isExcluded) return false;
          }
          // If both or neither, ignore.
        }

        // 4. Global Search
        if (filterState.query.isNotEmpty) {
          final q = filterState.query.toLowerCase();
          final matches = record.trainNumber.toLowerCase().contains(q) ||
              (record.subReason?.toLowerCase().contains(q) ?? false) ||
              (record.primaryDepartment?.toLowerCase().contains(q) ?? false) ||
              (record.remarks?.toLowerCase().contains(q) ?? false) ||
              (record.movementType?.toLowerCase().contains(q) ?? false);
          if (!matches) return false;
        }

        return true;
      }).toList();
    },
    orElse: () => [],
  );
});

// Helper to parse "2h 15m" or "0h 45m" to minutes
int _parsePddMinutes(String pdd) {
  try {
    final parts = pdd.split(' ');
    int hours = 0;
    int minutes = 0;
    for (var part in parts) {
      if (part.endsWith('h')) {
        hours = int.parse(part.replaceAll('h', ''));
      } else if (part.endsWith('m')) {
        minutes = int.parse(part.replaceAll('m', ''));
      }
    }
    return hours * 60 + minutes;
  } catch (e) {
    return 0;
  }
}

// Summary Logic
final recordsSummaryProvider = Provider<TrainRecordSummary>((ref) {
  final records = ref.watch(filteredRecordsProvider);

  if (records.isEmpty) {
    return TrainRecordSummary(
        totalRecords: 0,
        totalPdd: '0h 0m',
        averagePdd: '0m',
        cleanAveragePdd: '0m',
        highestDelay: '0h 0m');
  }

  int totalMinutes = 0;
  int maxMinutes = 0;
  
  int cleanTotalMinutes = 0;
  int cleanCount = 0;

  for (var r in records) {
    final m = _parsePddMinutes(r.pdd);
    totalMinutes += m;
    if (m > maxMinutes) maxMinutes = m;
    
    if (!r.isExcluded) {
      cleanTotalMinutes += m;
      cleanCount++;
    }
  }

  return TrainRecordSummary(
    totalRecords: records.length,
    totalPdd: _formatMinutes(totalMinutes),
    averagePdd: '${(totalMinutes / records.length).toStringAsFixed(0)}m',
    cleanAveragePdd: cleanCount == 0 ? '0m' : '${(cleanTotalMinutes / cleanCount).toStringAsFixed(0)}m',
    highestDelay: _formatMinutes(maxMinutes),
  );
});

class TrainRecordSummary {
  final int totalRecords;
  final String totalPdd;
  final String averagePdd; // Raw average
  final String cleanAveragePdd; // Excluding excluded records
  final String highestDelay; // Max PDD

  TrainRecordSummary({
    required this.totalRecords,
    required this.totalPdd,
    required this.averagePdd,
    required this.cleanAveragePdd,
    required this.highestDelay,
  });
}

String _formatMinutes(int totalMinutes) {
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  return '${h}h ${m}m';
}
