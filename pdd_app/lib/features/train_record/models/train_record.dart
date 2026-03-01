import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'train_record.g.dart';

enum Department {
  operating,
  mechanical,
  electrical,
  snt,
  commercial,
  security,
  external,
  interDept,
  unknown;

  String get label {
    switch (this) {
      case Department.operating: return 'Operating (Traffic)';
      case Department.mechanical: return 'Mechanical (C&W)';
      case Department.electrical: return 'Electrical (TRD / Loco)';
      case Department.snt: return 'Signalling & Telecom (S&T)';
      case Department.commercial: return 'Commercial';
      case Department.security: return 'Security / RPF';
      case Department.external: return 'External / Force Majeure';
      case Department.interDept: return 'Inter-Departmental / Control';
      case Department.unknown: return 'Unknown';
    }
  }

  static Department fromString(String? value) {
    if (value == null) return Department.unknown;
    // Try to match enum name first
    try {
      return Department.values.firstWhere((e) => e.name == value);
    } catch (_) {
      // Fallback: match label or partial parts (legacy data support)
      return Department.values.firstWhere(
        (e) => value.toLowerCase().contains(e.name) || e.label == value,
        orElse: () => Department.unknown,
      );
    }
  }
}

@JsonSerializable()
class TrainRecord {
  final String id;
  final DateTime date;
  final String trainNumber;
  final String rollingStock;
  
  final String? signOnTime;
  final String? tocTime;
  final String? readyTime;
  final String? departureTime;
  
  final String? locoDelay;
  final String? cwDelay;
  final String? trafficDelay;
  final String? otherDelay;
  
  final String? actualTimeTaken;
  final String? remarks;
  
  final String status;
  // Legacy PDD string, kept for sync or display if needed, but primary is now pddMinutes
  final String pdd; 
  
  final String? direction;
  final String? trainType;
  final String? movementType;
  final String? scheduledDeparture;
  final String? actualDeparture;
  
  @JsonKey(fromJson: Department.fromString, toJson: _deptToString)
  final Department primaryDepartment;
  
  final String subReason; // Non-nullable now
  
  final String? crewTime; // Formatting string kept for now
  
  final bool isExcluded;

  // New Integer Fields
  final int pddMinutes;
  final int crewTimeMinutes;

  TrainRecord({
    required this.id,
    required this.date,
    required this.trainNumber,
    required this.rollingStock,
    this.signOnTime,
    this.tocTime,
    this.readyTime,
    this.departureTime,
    this.locoDelay,
    this.cwDelay,
    this.trafficDelay,
    this.otherDelay,
    this.actualTimeTaken,
    this.remarks,
    this.status = 'In Progress',
    this.pdd = '0:00',
    this.direction,
    this.trainType,
    this.movementType,
    this.scheduledDeparture,
    this.actualDeparture,
    this.primaryDepartment = Department.unknown,
    this.subReason = 'Unknown',
    this.crewTime,
    this.isExcluded = false,
    this.pddMinutes = 0,
    this.crewTimeMinutes = 0,
  });

  static String _deptToString(Department d) => d.name;

  // --- Logic Moved from UI ---

  // 1. Formatted PDD for Display
  String get pddFormatted {
    // If we have minutes, use them for accurate formatting
    if (pddMinutes > 0) {
      final h = pddMinutes ~/ 60;
      final m = pddMinutes % 60;
      return '${h}h ${m}m';
    }
    return pdd; // Fallback to legacy string
  }

  // 2. PDD Severity Color
  Color get pddColor {
    if (pddMinutes == 0) return const Color(0xFF4CAF50); // Material Green 500
    if (pddMinutes <= 30) return const Color(0xFFFF9800); // Material Orange 500
    return const Color(0xFFF44336); // Material Red 500
  }

  // Utility (Existing)
  static Duration? parseTime(String? timeStr) => _parseTime(timeStr);
  
  static Duration? _parseTime(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return Duration(hours: hours, minutes: minutes);
  }

  static String formatMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  static String formatDuration(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String calculatePDD(String? later, String? earlier) {
    if (later == null || earlier == null) return '0h 0m';
    final partsLater = later.split(':');
    final partsEarlier = earlier.split(':');
    if (partsLater.length != 2 || partsEarlier.length != 2) return '0h 0m';
    
    final h1 = int.tryParse(partsLater[0]) ?? 0;
    final m1 = int.tryParse(partsLater[1]) ?? 0;
    final h2 = int.tryParse(partsEarlier[0]) ?? 0;
    final m2 = int.tryParse(partsEarlier[1]) ?? 0;
    
    int diff = (h1 * 60 + m1) - (h2 * 60 + m2);
    if (diff < 0) diff += 1440;
    
    return formatMinutes(diff);
  }

  static String calculateTotalDelay(List<String?> delays) {
    int total = 0;
    for (var d in delays) {
      if (d == null || !d.contains(':')) continue;
      final parts = d.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      total += (h * 60 + m);
    }
    final h = total ~/ 60;
    final m = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  factory TrainRecord.fromJson(Map<String, dynamic> json) => _$TrainRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TrainRecordToJson(this);
  
  // CopyWith (Manual or generator, useful for immutable updates)
  TrainRecord copyWith({
     String? id,
     int? pddMinutes,
     // ... add others as needed
  }) {
    return TrainRecord(
      id: id ?? this.id,
      date: date,
      trainNumber: trainNumber,
      rollingStock: rollingStock,
      pddMinutes: pddMinutes ?? this.pddMinutes,
      // ...
      // For brevity in this fix plan, assuming basic functionality.
      // If we use Freezed in future, this is easier.
      signOnTime: signOnTime,
      tocTime: tocTime,
      readyTime: readyTime,
      departureTime: departureTime,
      primaryDepartment: primaryDepartment,
      subReason: subReason,
      isExcluded: isExcluded,
      pdd: pdd,
      crewTime: crewTime,
      crewTimeMinutes: crewTimeMinutes,
    );
  }
}
