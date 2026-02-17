import 'package:json_annotation/json_annotation.dart';

part 'train_record.g.dart';

@JsonSerializable()
class TrainRecord {
  final String id;
  final DateTime date;
  final String trainNumber;
  final String rollingStock;
  
  // Times (stored as strings HH:mm for simplicity to match JS)
  final String? signOnTime;
  final String? tocTime;
  final String? readyTime;
  final String? departureTime;

  // Delays (stored as Duration represented as strings HH:mm)
  final String? locoDelay;
  final String? cwDelay;
  final String? trafficDelay;
  final String? otherDelay;
  
  final String? actualTimeTaken;
  final String? remarks;
  
  final String status; // Completed, Delayed, In Progress
  final String status; // Completed, Delayed, In Progress
  final String pdd; // Formatted PDD string
  
  // New fields
  final String? direction;
  final String? trainType;
  final String? movementType;
  final String? scheduledDeparture;
  final String? actualDeparture;
  final String? primaryDepartment;
  final String? subReason;
  final String? crewTime;
  final bool isExcluded;

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
    this.status = 'In Progress',
    this.pdd = '0:00',
    this.direction,
    this.trainType,
    this.movementType,
    this.scheduledDeparture,
    this.actualDeparture,
    this.primaryDepartment,
    this.subReason,
    this.crewTime,
    this.isExcluded = false,
  });

  // Utility to parse HH:mm to Duration
  static Duration? parseTime(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return Duration(hours: hours, minutes: minutes);
  }

  // Utility to format Duration to HH:mm string
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Calculate PDD based on Departure and Ready Time
  static String calculatePDD(String? departureTime, String? readyTime) {
    final dep = parseTime(departureTime);
    final ready = parseTime(readyTime);
    if (dep == null || ready == null) return '0:00';
    
    // Simplistic calculation: dep - ready. 
    // If dep < ready, assume it's next day (though unlikely for PDD, let's keep it simple for now)
    var diff = dep.inMinutes - ready.inMinutes;
    if (diff < 0) diff += 24 * 60; // Add a day in minutes
    
    final h = diff ~/ 60;
    final m = diff % 60;
    return '${h}h ${m}m';
  }

  // Calculate Total Delay
  static String calculateTotalDelay(List<String?> delays) {
    int totalMinutes = 0;
    for (final d in delays) {
      final duration = parseTime(d);
      if (duration != null) {
        totalMinutes += duration.inMinutes;
      }
    }
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  factory TrainRecord.fromJson(Map<String, dynamic> json) => _$TrainRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TrainRecordToJson(this);
}
