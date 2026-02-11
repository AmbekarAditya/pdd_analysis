import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'app_database.g.dart';

class TrainRecordEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get trainNumber => text()();
  TextColumn get rollingStock => text()();
  TextColumn get signOnTime => text().nullable()();
  TextColumn get tocTime => text().nullable()();
  TextColumn get readyTime => text().nullable()();
  TextColumn get departureTime => text().nullable()();
  TextColumn get locoDelay => text().nullable()();
  TextColumn get cwDelay => text().nullable()();
  TextColumn get trafficDelay => text().nullable()();
  TextColumn get otherDelay => text().nullable()();
  TextColumn get actualTimeTaken => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('In Progress'))();
  TextColumn get pdd => text().withDefault(const Constant('0:00'))();
}

@DriftDatabase(tables: [TrainRecordEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
