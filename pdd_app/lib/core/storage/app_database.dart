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
  // New columns for Refactor
  TextColumn get direction => text().nullable()(); // UP/DN
  TextColumn get trainType => text().nullable()();
  TextColumn get movementType => text().nullable()();
  TextColumn get scheduledDeparture => text().nullable()();
  TextColumn get actualDeparture => text().nullable()();
  TextColumn get primaryDepartment => text().nullable()();
  TextColumn get subReason => text().nullable()();
  TextColumn get crewTime => text().nullable()(); // stored as minutes or HH:MM? Plan says minutes. Storing as Text for flexibility or Int. Let's use Text to keep consistent with others or Int if pure minutes. Plan say "Total PDD (minutes)". Let's stick to Text "HH:MM" for consistency with other duration fields, or String "X min". Let's use Text.
  BoolColumn get isExcluded => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [TrainRecordEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  @override
  int get schemaVersion => 2; // Bump version
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(trainRecordEntries, trainRecordEntries.direction);
          await m.addColumn(trainRecordEntries, trainRecordEntries.trainType);
          await m.addColumn(trainRecordEntries, trainRecordEntries.movementType);
          await m.addColumn(trainRecordEntries, trainRecordEntries.scheduledDeparture);
          await m.addColumn(trainRecordEntries, trainRecordEntries.actualDeparture);
          await m.addColumn(trainRecordEntries, trainRecordEntries.primaryDepartment);
          await m.addColumn(trainRecordEntries, trainRecordEntries.subReason);
          await m.addColumn(trainRecordEntries, trainRecordEntries.crewTime);
          await m.addColumn(trainRecordEntries, trainRecordEntries.isExcluded);
        }
      },
    );
  }
}
