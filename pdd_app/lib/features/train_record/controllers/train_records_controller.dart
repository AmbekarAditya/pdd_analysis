import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/record_filter_state.dart';
import '../models/train_record.dart';
import '../providers/record_providers.dart';

// Notifier for the Filter State (Riverpod 2.0+ style)
class TrainRecordsController extends Notifier<RecordFilterState> {
  @override
  RecordFilterState build() {
    return const RecordFilterState();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  void setTrainFilters({
    String? trainNumber,
    String? direction,
    String? trainType,
    String? movementType,
  }) {
    state = state.copyWith(
      trainNumber: trainNumber,
      direction: direction,
      trainType: trainType,
      movementType: movementType,
    );
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

  void toggleSubReason(String reason) {
    final current = List<String>.from(state.selectedSubReasons);
    if (current.contains(reason)) {
      current.remove(reason);
    } else {
      current.add(reason);
    }
    state = state.copyWith(selectedSubReasons: current);
  }

  void setPddRange(RangeValues? range) {
    state = state.copyWith(pddRange: range);
  }

  void setExcludeFilter(ExcludeFilter filter) {
    state = state.copyWith(excludeFilter: filter);
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
        // 1. Global Search
        if (filterState.query.isNotEmpty) {
          final q = filterState.query.toLowerCase();
          final matches = record.trainNumber.toLowerCase().contains(q) ||
              (record.subReason?.toLowerCase().contains(q) ?? false) ||
              (record.primaryDepartment?.toLowerCase().contains(q) ?? false) ||
              (record.remarks?.toLowerCase().contains(q) ?? false) ||
              (record.movementType?.toLowerCase().contains(q) ?? false);
          if (!matches) return false;
        }

        // 2. Date Range
        if (filterState.dateRange != null) {
          if (record.date.isBefore(filterState.dateRange!.start) ||
              record.date.isAfter(filterState.dateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        // 3. Train Filters
        if (filterState.trainNumber != null &&
            filterState.trainNumber!.isNotEmpty &&
            !record.trainNumber.contains(filterState.trainNumber!)) {
          return false;
        }
        if (filterState.direction != null &&
             filterState.direction != 'All' && 
            record.direction != filterState.direction) {
          return false;
        }
        if (filterState.trainType != null &&
            filterState.trainType != 'All' &&
            record.trainType != filterState.trainType) {
          return false;
        }
        if (filterState.movementType != null &&
            filterState.movementType != 'All' &&
            record.movementType != filterState.movementType) {
          return false;
        }

        // 4. Department Filter
        if (filterState.selectedDepartments.isNotEmpty) {
          if (record.primaryDepartment == null ||
              !filterState.selectedDepartments.contains(record.primaryDepartment)) {
            return false;
          }
        }

        // 5. Sub-Reason Filter
        if (filterState.selectedSubReasons.isNotEmpty) {
          if (record.subReason == null ||
              !filterState.selectedSubReasons.contains(record.subReason)) {
            return false;
          }
        }

        // 6. PDD Range
        if (filterState.pddRange != null) {
          final pddMinutes = _parsePddMinutes(record.pdd);
          if (pddMinutes < filterState.pddRange!.start ||
              pddMinutes > filterState.pddRange!.end) {
            return false;
          }
        }

        // 7. Exclude Filter
        if (filterState.excludeFilter == ExcludeFilter.excludedOnly &&
            !record.isExcluded) {
          return false;
        }
        if (filterState.excludeFilter == ExcludeFilter.nonExcludedOnly &&
            record.isExcluded) {
          return false;
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

// Summary Model
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

// Computed Provider: Summary
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

String _formatMinutes(int totalMinutes) {
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  return '${h}h ${m}m';
}
