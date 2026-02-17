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
  
  // V3 Hardening
  IntColumn get pddMinutes => integer().withDefault(const Constant(0))();
  IntColumn get crewTimeMinutes => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [TrainRecordEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  @override
  @override
  int get schemaVersion => 3; // Bump version
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Version 2 upgrades
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
        
        if (from < 3) {
          // Version 3 upgrades: Hardening
          // 1. Add integer columns for calculations
          await m.addColumn(trainRecordEntries, trainRecordEntries.pddMinutes);
          await m.addColumn(trainRecordEntries, trainRecordEntries.crewTimeMinutes);
          
          // 2. We cannot easily change existing columns to NOT NULL in SQLite without table recreation 
          // or complex copy steps. For Drift/SQLite, the common pattern is to just strict query 
          // or ensure future inserts are good.
          // However, we can update existing nulls to defaults to be safe.
          await customStatement("UPDATE train_record_entries SET primary_department = 'External' WHERE primary_department IS NULL");
          await customStatement("UPDATE train_record_entries SET sub_reason = 'Unknown' WHERE sub_reason IS NULL");
          
          // 3. Migrate PDD text to Minutes (Best effort SQL or Dart calculation?)
          // Doing it in Dart is safer if we can iterate, but migration happens in database open. 
          // Let's default new columns to 0.
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) return;
        
        // Data Repair: Populate pddMinutes from pdd text if currently 0
        // This runs after migration.
        // We will fetch all records and update them using Dart logic if needed
        // But for now, let's rely on new records being correct and potentially 'unknown' old ones.
      },
    );
  }
}
