import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/record_filter_state.dart';
import '../models/train_record.dart';
import '../providers/record_providers.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

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
  final period = ref.watch(analysisPeriodProvider);

  return allRecordsAsync.maybeWhen(
    data: (records) {
      return records.where((record) {
        // 1. Date Filter (Synced with Dashboard)
        // Check if record date is within the global AnalysisPeriod range
        // Add 1 second buffer to be inclusive if times are exact boundaries, 
        // though usually Start is 00:00:00 and End is 23:59:59.
        final rDate = record.date;
        if (rDate.isBefore(period.startDate) || rDate.isAfter(period.endDate)) {
          return false;
        }

        // 2. Department Filter (OR logic: if record has Dep A AND Dep A is selected -> keep)
        // If selection is empty, show all.
        if (filterState.selectedDepartments.isNotEmpty) {
          // Compare Enum Label (e.g. 'Operating (Traffic)') with Selected String
          if (!filterState.selectedDepartments.contains(record.primaryDepartment.label)) {
            return false;
          }
        }

        // 3. Status Filters (Mixed logic)
        // Separate status filters into sets
        final statusFilters = filterState.selectedStatusFilters;
        if (statusFilters.isNotEmpty) {
          bool keep = true;
          
          // A. Delay Magnitude (High vs Zero)
          final hasHighDelay = statusFilters.contains(RecordStatusFilter.highDelay);
          final hasHighCrewTime = statusFilters.contains(RecordStatusFilter.highCrewTime);
          
          if (hasHighDelay || hasHighCrewTime) {
             bool matchesDelay = false;
             if (hasHighDelay && record.pddMinutes > 45) matchesDelay = true;
             if (hasHighCrewTime && record.crewTimeMinutes > 30) matchesDelay = true;
             
             if (!matchesDelay) return false;
          }

          // B. Exclusion (Unavoidable vs Avoidable)
          final hasUnavoidable = statusFilters.contains(RecordStatusFilter.unavoidable);
          final hasAvoidable = statusFilters.contains(RecordStatusFilter.avoidable);
          
          if (hasUnavoidable && !hasAvoidable) {
            if (!record.isExcluded) return false;
          } else if (hasAvoidable && !hasUnavoidable) {
            if (record.isExcluded) return false;
          }
        }

        // 4. Global Search
        if (filterState.query.isNotEmpty) {
          final q = filterState.query.toLowerCase();
          final matches = record.trainNumber.toLowerCase().contains(q) ||
              (record.subReason.toLowerCase().contains(q)) ||
              (record.primaryDepartment.label.toLowerCase().contains(q)) || // Enum label
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

// Summary Logic
final recordsSummaryProvider = Provider<TrainRecordSummary>((ref) {
  final records = ref.watch(filteredRecordsProvider);

  if (records.isEmpty) {
    return TrainRecordSummary(
        totalRecords: 0,
        totalPdd: '0h 0m',
        averagePdd: '0m',
        avoidableAveragePdd: '0m',
        highestDelay: '0h 0m');
  }

  int totalMinutes = 0;
  int maxMinutes = 0;
  
  int avoidablePddSum = 0;
  int avoidableCount = 0;

  for (var r in records) {
    final m = r.pddMinutes; // Direct int access
    totalMinutes += m;
    if (m > maxMinutes) maxMinutes = m;
    
    if (!r.isExcluded) {
      avoidablePddSum += m;
      avoidableCount++;
    }
  }

  return TrainRecordSummary(
    totalRecords: records.length,
    totalPdd: _formatMinutes(totalMinutes),
    averagePdd: '${(totalMinutes / records.length).toStringAsFixed(0)}m',
    avoidableAveragePdd: avoidableCount == 0 ? '0m' : '${(avoidablePddSum / avoidableCount).toStringAsFixed(0)}m',
    highestDelay: _formatMinutes(maxMinutes),
  );
});

// ... TrainRecordSummary class ...

String _formatMinutes(int totalMinutes) {
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  return '${h}h ${m}m';
}

class TrainRecordSummary {
  final int totalRecords;
  final String totalPdd;
  final String averagePdd; // Raw average
  final String avoidableAveragePdd; // Excluding unavoidable records
  final String highestDelay; // Max PDD

  TrainRecordSummary({
    required this.totalRecords,
    required this.totalPdd,
    required this.averagePdd,
    required this.avoidableAveragePdd,
    required this.highestDelay,
  });
}
