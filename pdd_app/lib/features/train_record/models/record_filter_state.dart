import 'package:flutter/material.dart';

enum DateFilterPreset { all, today, last7Days, thisMonth }
enum RecordStatusFilter { excluded, nonExcluded, highDelay, zeroDelay }

@immutable
class RecordFilterState {
  final String query;
  final DateFilterPreset dateFilter;
  final List<String> selectedDepartments;
  final List<RecordStatusFilter> selectedStatusFilters;

  const RecordFilterState({
    this.query = '',
    this.dateFilter = DateFilterPreset.all,
    this.selectedDepartments = const [],
    this.selectedStatusFilters = const [],
  });

  RecordFilterState copyWith({
    String? query,
    DateFilterPreset? dateFilter,
    List<String>? selectedDepartments,
    List<RecordStatusFilter>? selectedStatusFilters,
  }) {
    return RecordFilterState(
      query: query ?? this.query,
      dateFilter: dateFilter ?? this.dateFilter,
      selectedDepartments: selectedDepartments ?? this.selectedDepartments,
      selectedStatusFilters: selectedStatusFilters ?? this.selectedStatusFilters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordFilterState &&
        other.query == query &&
        other.dateFilter == dateFilter &&
        other.selectedDepartments == selectedDepartments && // List equality check needed usually, but assuming immutable list ref change
        other.selectedStatusFilters == selectedStatusFilters;
  }

  @override
  int get hashCode {
    return Object.hash(
      query,
      dateFilter,
      Object.hashAll(selectedDepartments),
      Object.hashAll(selectedStatusFilters),
    );
  }
}
