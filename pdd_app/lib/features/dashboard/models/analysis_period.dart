import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PeriodPreset {
  today,
  last7Days,
  thisMonth,
  custom,
}

class AnalysisPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final PeriodPreset preset;

  const AnalysisPeriod({
    required this.startDate,
    required this.endDate,
    required this.preset,
  });

  // Equality override for Riverpod to detect changes correctly if needed, 
  // but const constructor + immutable fields usually suffices for simple equality.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisPeriod &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          preset == other.preset;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode ^ preset.hashCode;
}
