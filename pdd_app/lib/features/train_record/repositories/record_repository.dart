import 'package:drift/drift.dart';
import '../models/train_record.dart';
import '../../../core/storage/app_database.dart';

abstract class RecordRepository {
  Stream<List<TrainRecord>> watchAllRecords();
  Future<void> addRecord(TrainRecord record);
  Future<void> updateRecord(TrainRecord record);
  Future<void> deleteRecord(String id);
}

class RecordRepositoryImpl implements RecordRepository {
  final AppDatabase _db;

  RecordRepositoryImpl(this._db);

  @override
  Stream<List<TrainRecord>> watchAllRecords() {
    return (_db.select(_db.trainRecordEntries)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) {
      return rows.map((row) => _mapToModel(row)).toList();
    });
  }

  @override
  Future<void> addRecord(TrainRecord record) async {
    await _db.into(_db.trainRecordEntries).insert(_mapToCompanion(record));
  }

  @override
  Future<void> updateRecord(TrainRecord record) async {
    final id = int.tryParse(record.id);
    if (id == null) return;
    
    await (_db.update(_db.trainRecordEntries)
          ..where((t) => t.id.equals(id)))
        .write(_mapToCompanion(record));
  }

  @override
  Future<void> deleteRecord(String id) async {
    final entryId = int.tryParse(id);
    if (entryId == null) return;

    await (_db.delete(_db.trainRecordEntries)
          ..where((t) => t.id.equals(entryId)))
        .go();
  }

  TrainRecord _mapToModel(TrainRecordEntry row) {
    return TrainRecord(
      id: row.id.toString(),
      date: row.date,
      trainNumber: row.trainNumber,
      rollingStock: row.rollingStock,
      signOnTime: row.signOnTime,
      tocTime: row.tocTime,
      readyTime: row.readyTime,
      departureTime: row.departureTime,
      locoDelay: row.locoDelay,
      cwDelay: row.cwDelay,
      trafficDelay: row.trafficDelay,
      otherDelay: row.otherDelay,
      actualTimeTaken: row.actualTimeTaken,
      remarks: row.remarks,
      status: row.status,
      pdd: row.pdd,
      // New mappings
      direction: row.direction,
      trainType: row.trainType,
      movementType: row.movementType,
      scheduledDeparture: row.scheduledDeparture,
      actualDeparture: row.actualDeparture,
      primaryDepartment: Department.fromString(row.primaryDepartment),
      subReason: row.subReason ?? 'Unknown',
      crewTime: row.crewTime,
      isExcluded: row.isExcluded,
      pddMinutes: row.pddMinutes,
      crewTimeMinutes: row.crewTimeMinutes,
    );
  }

  TrainRecordEntriesCompanion _mapToCompanion(TrainRecord record) {
    return TrainRecordEntriesCompanion.insert(
      date: record.date,
      trainNumber: record.trainNumber,
      rollingStock: record.rollingStock,
      signOnTime: Value(record.signOnTime),
      tocTime: Value(record.tocTime),
      readyTime: Value(record.readyTime),
      departureTime: Value(record.departureTime),
      locoDelay: Value(record.locoDelay),
      cwDelay: Value(record.cwDelay),
      trafficDelay: Value(record.trafficDelay),
      otherDelay: Value(record.otherDelay),
      actualTimeTaken: Value(record.actualTimeTaken),
      remarks: Value(record.remarks),
      status: Value(record.status),
      pdd: Value(record.pdd),
      // New mappings
      direction: Value(record.direction),
      trainType: Value(record.trainType),
      movementType: Value(record.movementType),
      scheduledDeparture: Value(record.scheduledDeparture),
      actualDeparture: Value(record.actualDeparture),
      primaryDepartment: Value(record.primaryDepartment.name),
      subReason: Value(record.subReason),
      crewTime: Value(record.crewTime),
      isExcluded: Value(record.isExcluded),
      pddMinutes: Value(record.pddMinutes),
      crewTimeMinutes: Value(record.crewTimeMinutes),
    );
  }
}
