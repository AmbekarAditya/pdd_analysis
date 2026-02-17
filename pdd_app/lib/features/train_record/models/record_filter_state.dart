import 'package:flutter/material.dart';

enum ExcludeFilter { all, excludedOnly, nonExcludedOnly }

@immutable
class RecordFilterState {
  final String query;
  final DateTimeRange? dateRange;
  final String? trainNumber;
  final String? direction;
  final String? trainType;
  final String? movementType;
  final List<String> selectedDepartments;
  final List<String> selectedSubReasons;
  final RangeValues? pddRange;
  final ExcludeFilter excludeFilter;

  const RecordFilterState({
    this.query = '',
    this.dateRange,
    this.trainNumber,
    this.direction,
    this.trainType,
    this.movementType,
    this.selectedDepartments = const [],
    this.selectedSubReasons = const [],
    this.pddRange,
    this.excludeFilter = ExcludeFilter.all,
  });

  RecordFilterState copyWith({
    String? query,
    DateTimeRange? dateRange,
    String? trainNumber,
    String? direction,
    String? trainType,
    String? movementType,
    List<String>? selectedDepartments,
    List<String>? selectedSubReasons,
    RangeValues? pddRange,
    ExcludeFilter? excludeFilter,
  }) {
    return RecordFilterState(
      query: query ?? this.query,
      dateRange: dateRange ?? this.dateRange,
      trainNumber: trainNumber ?? this.trainNumber,
      direction: direction ?? this.direction,
      trainType: trainType ?? this.trainType,
      movementType: movementType ?? this.movementType,
      selectedDepartments: selectedDepartments ?? this.selectedDepartments,
      selectedSubReasons: selectedSubReasons ?? this.selectedSubReasons,
      pddRange: pddRange ?? this.pddRange,
      excludeFilter: excludeFilter ?? this.excludeFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordFilterState &&
        other.query == query &&
        other.dateRange == dateRange &&
        other.trainNumber == trainNumber &&
        other.direction == direction &&
        other.trainType == trainType &&
        other.movementType == movementType &&
        other.selectedDepartments == selectedDepartments &&
        other.selectedSubReasons == selectedSubReasons &&
        other.pddRange == pddRange &&
        other.excludeFilter == excludeFilter;
  }

  @override
  int get hashCode {
    return Object.hash(
      query,
      dateRange,
      trainNumber,
      direction,
      trainType,
      movementType,
      selectedDepartments,
      selectedSubReasons,
      pddRange,
      excludeFilter,
    );
  }
}
