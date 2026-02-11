import 'package:intl/intl.dart';

class DailyStats {
  final DateTime date;
  final int totalTrains;
  final Duration averagePDD;
  final int trainsBelow45;

  DailyStats({
    required this.date,
    required this.totalTrains,
    required this.averagePDD,
    required this.trainsBelow45,
  });

  String get dateString => DateFormat('MMM d').format(date);
  String get pddString {
    final hours = averagePDD.inHours;
    final minutes = averagePDD.inMinutes.remainder(60);
    final seconds = averagePDD.inSeconds.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get percentBelow45 => totalTrains == 0 ? 0 : (trainsBelow45 / totalTrains) * 100;
}
