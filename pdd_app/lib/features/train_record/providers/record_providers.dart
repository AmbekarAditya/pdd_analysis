import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/app_database.dart';
import '../repositories/record_repository.dart';
import '../models/train_record.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepositoryImpl(ref.watch(databaseProvider));
});

final trainRecordsStreamProvider = StreamProvider<List<TrainRecord>>((ref) {
  return ref.watch(recordRepositoryProvider).watchAllRecords();
});
