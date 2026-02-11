import 'package:flutter_test/flutter_test.dart';
import 'package:pdd_app/features/train_record/models/train_record.dart';

void main() {
  group('TrainRecord Calculations', () {
    test('parseTime works correctly', () {
      expect(TrainRecord.parseTime('01:30'), equals(const Duration(hours: 1, minutes: 30)));
      expect(TrainRecord.parseTime('00:05'), equals(const Duration(minutes: 5)));
      expect(TrainRecord.parseTime('invalid'), isNull);
      expect(TrainRecord.parseTime(null), isNull);
    });

    test('formatDuration works correctly', () {
      expect(TrainRecord.formatDuration(const Duration(hours: 2, minutes: 45)), equals('02:45'));
      expect(TrainRecord.formatDuration(const Duration(minutes: 5)), equals('00:05'));
    });

    test('calculatePDD works correctly (same day)', () {
      expect(TrainRecord.calculatePDD('14:00', '13:00'), equals('1h 0m'));
      expect(TrainRecord.calculatePDD('13:30', '13:00'), equals('0h 30m'));
    });

    test('calculatePDD works correctly (next day wrap)', () {
      // 01:00 AM departure after 23:00 PM ready
      expect(TrainRecord.calculatePDD('01:00', '23:00'), equals('2h 0m'));
    });

    test('calculateTotalDelay works correctly', () {
      final delays = ['00:10', '00:05', '01:00', null, 'invalid'];
      expect(TrainRecord.calculateTotalDelay(delays), equals('01:15'));
    });

    test('calculateTotalDelay returns 00:00 for empty or invalid list', () {
      expect(TrainRecord.calculateTotalDelay([]), equals('00:00'));
      expect(TrainRecord.calculateTotalDelay(['invalid']), equals('00:00'));
    });
    group('PDD String Formatting', () {
      test('formats small durations', () {
         expect(TrainRecord.calculatePDD('10:15', '10:00'), equals('0h 15m'));
      });
  });
  });
}
