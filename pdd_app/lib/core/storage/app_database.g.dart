// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrainRecordEntriesTable extends TrainRecordEntries
    with TableInfo<$TrainRecordEntriesTable, TrainRecordEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainRecordEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _trainNumberMeta =
      const VerificationMeta('trainNumber');
  @override
  late final GeneratedColumn<String> trainNumber = GeneratedColumn<String>(
      'train_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rollingStockMeta =
      const VerificationMeta('rollingStock');
  @override
  late final GeneratedColumn<String> rollingStock = GeneratedColumn<String>(
      'rolling_stock', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _signOnTimeMeta =
      const VerificationMeta('signOnTime');
  @override
  late final GeneratedColumn<String> signOnTime = GeneratedColumn<String>(
      'sign_on_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tocTimeMeta =
      const VerificationMeta('tocTime');
  @override
  late final GeneratedColumn<String> tocTime = GeneratedColumn<String>(
      'toc_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _readyTimeMeta =
      const VerificationMeta('readyTime');
  @override
  late final GeneratedColumn<String> readyTime = GeneratedColumn<String>(
      'ready_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _departureTimeMeta =
      const VerificationMeta('departureTime');
  @override
  late final GeneratedColumn<String> departureTime = GeneratedColumn<String>(
      'departure_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locoDelayMeta =
      const VerificationMeta('locoDelay');
  @override
  late final GeneratedColumn<String> locoDelay = GeneratedColumn<String>(
      'loco_delay', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cwDelayMeta =
      const VerificationMeta('cwDelay');
  @override
  late final GeneratedColumn<String> cwDelay = GeneratedColumn<String>(
      'cw_delay', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trafficDelayMeta =
      const VerificationMeta('trafficDelay');
  @override
  late final GeneratedColumn<String> trafficDelay = GeneratedColumn<String>(
      'traffic_delay', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _otherDelayMeta =
      const VerificationMeta('otherDelay');
  @override
  late final GeneratedColumn<String> otherDelay = GeneratedColumn<String>(
      'other_delay', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actualTimeTakenMeta =
      const VerificationMeta('actualTimeTaken');
  @override
  late final GeneratedColumn<String> actualTimeTaken = GeneratedColumn<String>(
      'actual_time_taken', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('In Progress'));
  static const VerificationMeta _pddMeta = const VerificationMeta('pdd');
  @override
  late final GeneratedColumn<String> pdd = GeneratedColumn<String>(
      'pdd', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('0:00'));
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trainTypeMeta =
      const VerificationMeta('trainType');
  @override
  late final GeneratedColumn<String> trainType = GeneratedColumn<String>(
      'train_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _movementTypeMeta =
      const VerificationMeta('movementType');
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
      'movement_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledDepartureMeta =
      const VerificationMeta('scheduledDeparture');
  @override
  late final GeneratedColumn<String> scheduledDeparture =
      GeneratedColumn<String>('scheduled_departure', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actualDepartureMeta =
      const VerificationMeta('actualDeparture');
  @override
  late final GeneratedColumn<String> actualDeparture = GeneratedColumn<String>(
      'actual_departure', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _primaryDepartmentMeta =
      const VerificationMeta('primaryDepartment');
  @override
  late final GeneratedColumn<String> primaryDepartment =
      GeneratedColumn<String>('primary_department', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subReasonMeta =
      const VerificationMeta('subReason');
  @override
  late final GeneratedColumn<String> subReason = GeneratedColumn<String>(
      'sub_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _crewTimeMeta =
      const VerificationMeta('crewTime');
  @override
  late final GeneratedColumn<String> crewTime = GeneratedColumn<String>(
      'crew_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isExcludedMeta =
      const VerificationMeta('isExcluded');
  @override
  late final GeneratedColumn<bool> isExcluded = GeneratedColumn<bool>(
      'is_excluded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_excluded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _pddMinutesMeta =
      const VerificationMeta('pddMinutes');
  @override
  late final GeneratedColumn<int> pddMinutes = GeneratedColumn<int>(
      'pdd_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _crewTimeMinutesMeta =
      const VerificationMeta('crewTimeMinutes');
  @override
  late final GeneratedColumn<int> crewTimeMinutes = GeneratedColumn<int>(
      'crew_time_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        trainNumber,
        rollingStock,
        signOnTime,
        tocTime,
        readyTime,
        departureTime,
        locoDelay,
        cwDelay,
        trafficDelay,
        otherDelay,
        actualTimeTaken,
        remarks,
        status,
        pdd,
        direction,
        trainType,
        movementType,
        scheduledDeparture,
        actualDeparture,
        primaryDepartment,
        subReason,
        crewTime,
        isExcluded,
        pddMinutes,
        crewTimeMinutes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'train_record_entries';
  @override
  VerificationContext validateIntegrity(Insertable<TrainRecordEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('train_number')) {
      context.handle(
          _trainNumberMeta,
          trainNumber.isAcceptableOrUnknown(
              data['train_number']!, _trainNumberMeta));
    } else if (isInserting) {
      context.missing(_trainNumberMeta);
    }
    if (data.containsKey('rolling_stock')) {
      context.handle(
          _rollingStockMeta,
          rollingStock.isAcceptableOrUnknown(
              data['rolling_stock']!, _rollingStockMeta));
    } else if (isInserting) {
      context.missing(_rollingStockMeta);
    }
    if (data.containsKey('sign_on_time')) {
      context.handle(
          _signOnTimeMeta,
          signOnTime.isAcceptableOrUnknown(
              data['sign_on_time']!, _signOnTimeMeta));
    }
    if (data.containsKey('toc_time')) {
      context.handle(_tocTimeMeta,
          tocTime.isAcceptableOrUnknown(data['toc_time']!, _tocTimeMeta));
    }
    if (data.containsKey('ready_time')) {
      context.handle(_readyTimeMeta,
          readyTime.isAcceptableOrUnknown(data['ready_time']!, _readyTimeMeta));
    }
    if (data.containsKey('departure_time')) {
      context.handle(
          _departureTimeMeta,
          departureTime.isAcceptableOrUnknown(
              data['departure_time']!, _departureTimeMeta));
    }
    if (data.containsKey('loco_delay')) {
      context.handle(_locoDelayMeta,
          locoDelay.isAcceptableOrUnknown(data['loco_delay']!, _locoDelayMeta));
    }
    if (data.containsKey('cw_delay')) {
      context.handle(_cwDelayMeta,
          cwDelay.isAcceptableOrUnknown(data['cw_delay']!, _cwDelayMeta));
    }
    if (data.containsKey('traffic_delay')) {
      context.handle(
          _trafficDelayMeta,
          trafficDelay.isAcceptableOrUnknown(
              data['traffic_delay']!, _trafficDelayMeta));
    }
    if (data.containsKey('other_delay')) {
      context.handle(
          _otherDelayMeta,
          otherDelay.isAcceptableOrUnknown(
              data['other_delay']!, _otherDelayMeta));
    }
    if (data.containsKey('actual_time_taken')) {
      context.handle(
          _actualTimeTakenMeta,
          actualTimeTaken.isAcceptableOrUnknown(
              data['actual_time_taken']!, _actualTimeTakenMeta));
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('pdd')) {
      context.handle(
          _pddMeta, pdd.isAcceptableOrUnknown(data['pdd']!, _pddMeta));
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    }
    if (data.containsKey('train_type')) {
      context.handle(_trainTypeMeta,
          trainType.isAcceptableOrUnknown(data['train_type']!, _trainTypeMeta));
    }
    if (data.containsKey('movement_type')) {
      context.handle(
          _movementTypeMeta,
          movementType.isAcceptableOrUnknown(
              data['movement_type']!, _movementTypeMeta));
    }
    if (data.containsKey('scheduled_departure')) {
      context.handle(
          _scheduledDepartureMeta,
          scheduledDeparture.isAcceptableOrUnknown(
              data['scheduled_departure']!, _scheduledDepartureMeta));
    }
    if (data.containsKey('actual_departure')) {
      context.handle(
          _actualDepartureMeta,
          actualDeparture.isAcceptableOrUnknown(
              data['actual_departure']!, _actualDepartureMeta));
    }
    if (data.containsKey('primary_department')) {
      context.handle(
          _primaryDepartmentMeta,
          primaryDepartment.isAcceptableOrUnknown(
              data['primary_department']!, _primaryDepartmentMeta));
    }
    if (data.containsKey('sub_reason')) {
      context.handle(_subReasonMeta,
          subReason.isAcceptableOrUnknown(data['sub_reason']!, _subReasonMeta));
    }
    if (data.containsKey('crew_time')) {
      context.handle(_crewTimeMeta,
          crewTime.isAcceptableOrUnknown(data['crew_time']!, _crewTimeMeta));
    }
    if (data.containsKey('is_excluded')) {
      context.handle(
          _isExcludedMeta,
          isExcluded.isAcceptableOrUnknown(
              data['is_excluded']!, _isExcludedMeta));
    }
    if (data.containsKey('pdd_minutes')) {
      context.handle(
          _pddMinutesMeta,
          pddMinutes.isAcceptableOrUnknown(
              data['pdd_minutes']!, _pddMinutesMeta));
    }
    if (data.containsKey('crew_time_minutes')) {
      context.handle(
          _crewTimeMinutesMeta,
          crewTimeMinutes.isAcceptableOrUnknown(
              data['crew_time_minutes']!, _crewTimeMinutesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainRecordEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainRecordEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      trainNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}train_number'])!,
      rollingStock: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rolling_stock'])!,
      signOnTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sign_on_time']),
      tocTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}toc_time']),
      readyTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ready_time']),
      departureTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}departure_time']),
      locoDelay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loco_delay']),
      cwDelay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cw_delay']),
      trafficDelay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}traffic_delay']),
      otherDelay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}other_delay']),
      actualTimeTaken: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}actual_time_taken']),
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      pdd: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pdd'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction']),
      trainType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}train_type']),
      movementType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}movement_type']),
      scheduledDeparture: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}scheduled_departure']),
      actualDeparture: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}actual_departure']),
      primaryDepartment: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}primary_department']),
      subReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_reason']),
      crewTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crew_time']),
      isExcluded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_excluded'])!,
      pddMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pdd_minutes'])!,
      crewTimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}crew_time_minutes'])!,
    );
  }

  @override
  $TrainRecordEntriesTable createAlias(String alias) {
    return $TrainRecordEntriesTable(attachedDatabase, alias);
  }
}

class TrainRecordEntry extends DataClass
    implements Insertable<TrainRecordEntry> {
  final int id;
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
  final String pdd;
  final String? direction;
  final String? trainType;
  final String? movementType;
  final String? scheduledDeparture;
  final String? actualDeparture;
  final String? primaryDepartment;
  final String? subReason;
  final String? crewTime;
  final bool isExcluded;
  final int pddMinutes;
  final int crewTimeMinutes;
  const TrainRecordEntry(
      {required this.id,
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
      required this.status,
      required this.pdd,
      this.direction,
      this.trainType,
      this.movementType,
      this.scheduledDeparture,
      this.actualDeparture,
      this.primaryDepartment,
      this.subReason,
      this.crewTime,
      required this.isExcluded,
      required this.pddMinutes,
      required this.crewTimeMinutes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['train_number'] = Variable<String>(trainNumber);
    map['rolling_stock'] = Variable<String>(rollingStock);
    if (!nullToAbsent || signOnTime != null) {
      map['sign_on_time'] = Variable<String>(signOnTime);
    }
    if (!nullToAbsent || tocTime != null) {
      map['toc_time'] = Variable<String>(tocTime);
    }
    if (!nullToAbsent || readyTime != null) {
      map['ready_time'] = Variable<String>(readyTime);
    }
    if (!nullToAbsent || departureTime != null) {
      map['departure_time'] = Variable<String>(departureTime);
    }
    if (!nullToAbsent || locoDelay != null) {
      map['loco_delay'] = Variable<String>(locoDelay);
    }
    if (!nullToAbsent || cwDelay != null) {
      map['cw_delay'] = Variable<String>(cwDelay);
    }
    if (!nullToAbsent || trafficDelay != null) {
      map['traffic_delay'] = Variable<String>(trafficDelay);
    }
    if (!nullToAbsent || otherDelay != null) {
      map['other_delay'] = Variable<String>(otherDelay);
    }
    if (!nullToAbsent || actualTimeTaken != null) {
      map['actual_time_taken'] = Variable<String>(actualTimeTaken);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['status'] = Variable<String>(status);
    map['pdd'] = Variable<String>(pdd);
    if (!nullToAbsent || direction != null) {
      map['direction'] = Variable<String>(direction);
    }
    if (!nullToAbsent || trainType != null) {
      map['train_type'] = Variable<String>(trainType);
    }
    if (!nullToAbsent || movementType != null) {
      map['movement_type'] = Variable<String>(movementType);
    }
    if (!nullToAbsent || scheduledDeparture != null) {
      map['scheduled_departure'] = Variable<String>(scheduledDeparture);
    }
    if (!nullToAbsent || actualDeparture != null) {
      map['actual_departure'] = Variable<String>(actualDeparture);
    }
    if (!nullToAbsent || primaryDepartment != null) {
      map['primary_department'] = Variable<String>(primaryDepartment);
    }
    if (!nullToAbsent || subReason != null) {
      map['sub_reason'] = Variable<String>(subReason);
    }
    if (!nullToAbsent || crewTime != null) {
      map['crew_time'] = Variable<String>(crewTime);
    }
    map['is_excluded'] = Variable<bool>(isExcluded);
    map['pdd_minutes'] = Variable<int>(pddMinutes);
    map['crew_time_minutes'] = Variable<int>(crewTimeMinutes);
    return map;
  }

  TrainRecordEntriesCompanion toCompanion(bool nullToAbsent) {
    return TrainRecordEntriesCompanion(
      id: Value(id),
      date: Value(date),
      trainNumber: Value(trainNumber),
      rollingStock: Value(rollingStock),
      signOnTime: signOnTime == null && nullToAbsent
          ? const Value.absent()
          : Value(signOnTime),
      tocTime: tocTime == null && nullToAbsent
          ? const Value.absent()
          : Value(tocTime),
      readyTime: readyTime == null && nullToAbsent
          ? const Value.absent()
          : Value(readyTime),
      departureTime: departureTime == null && nullToAbsent
          ? const Value.absent()
          : Value(departureTime),
      locoDelay: locoDelay == null && nullToAbsent
          ? const Value.absent()
          : Value(locoDelay),
      cwDelay: cwDelay == null && nullToAbsent
          ? const Value.absent()
          : Value(cwDelay),
      trafficDelay: trafficDelay == null && nullToAbsent
          ? const Value.absent()
          : Value(trafficDelay),
      otherDelay: otherDelay == null && nullToAbsent
          ? const Value.absent()
          : Value(otherDelay),
      actualTimeTaken: actualTimeTaken == null && nullToAbsent
          ? const Value.absent()
          : Value(actualTimeTaken),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      status: Value(status),
      pdd: Value(pdd),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
      trainType: trainType == null && nullToAbsent
          ? const Value.absent()
          : Value(trainType),
      movementType: movementType == null && nullToAbsent
          ? const Value.absent()
          : Value(movementType),
      scheduledDeparture: scheduledDeparture == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDeparture),
      actualDeparture: actualDeparture == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDeparture),
      primaryDepartment: primaryDepartment == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryDepartment),
      subReason: subReason == null && nullToAbsent
          ? const Value.absent()
          : Value(subReason),
      crewTime: crewTime == null && nullToAbsent
          ? const Value.absent()
          : Value(crewTime),
      isExcluded: Value(isExcluded),
      pddMinutes: Value(pddMinutes),
      crewTimeMinutes: Value(crewTimeMinutes),
    );
  }

  factory TrainRecordEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainRecordEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      trainNumber: serializer.fromJson<String>(json['trainNumber']),
      rollingStock: serializer.fromJson<String>(json['rollingStock']),
      signOnTime: serializer.fromJson<String?>(json['signOnTime']),
      tocTime: serializer.fromJson<String?>(json['tocTime']),
      readyTime: serializer.fromJson<String?>(json['readyTime']),
      departureTime: serializer.fromJson<String?>(json['departureTime']),
      locoDelay: serializer.fromJson<String?>(json['locoDelay']),
      cwDelay: serializer.fromJson<String?>(json['cwDelay']),
      trafficDelay: serializer.fromJson<String?>(json['trafficDelay']),
      otherDelay: serializer.fromJson<String?>(json['otherDelay']),
      actualTimeTaken: serializer.fromJson<String?>(json['actualTimeTaken']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      status: serializer.fromJson<String>(json['status']),
      pdd: serializer.fromJson<String>(json['pdd']),
      direction: serializer.fromJson<String?>(json['direction']),
      trainType: serializer.fromJson<String?>(json['trainType']),
      movementType: serializer.fromJson<String?>(json['movementType']),
      scheduledDeparture:
          serializer.fromJson<String?>(json['scheduledDeparture']),
      actualDeparture: serializer.fromJson<String?>(json['actualDeparture']),
      primaryDepartment:
          serializer.fromJson<String?>(json['primaryDepartment']),
      subReason: serializer.fromJson<String?>(json['subReason']),
      crewTime: serializer.fromJson<String?>(json['crewTime']),
      isExcluded: serializer.fromJson<bool>(json['isExcluded']),
      pddMinutes: serializer.fromJson<int>(json['pddMinutes']),
      crewTimeMinutes: serializer.fromJson<int>(json['crewTimeMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'trainNumber': serializer.toJson<String>(trainNumber),
      'rollingStock': serializer.toJson<String>(rollingStock),
      'signOnTime': serializer.toJson<String?>(signOnTime),
      'tocTime': serializer.toJson<String?>(tocTime),
      'readyTime': serializer.toJson<String?>(readyTime),
      'departureTime': serializer.toJson<String?>(departureTime),
      'locoDelay': serializer.toJson<String?>(locoDelay),
      'cwDelay': serializer.toJson<String?>(cwDelay),
      'trafficDelay': serializer.toJson<String?>(trafficDelay),
      'otherDelay': serializer.toJson<String?>(otherDelay),
      'actualTimeTaken': serializer.toJson<String?>(actualTimeTaken),
      'remarks': serializer.toJson<String?>(remarks),
      'status': serializer.toJson<String>(status),
      'pdd': serializer.toJson<String>(pdd),
      'direction': serializer.toJson<String?>(direction),
      'trainType': serializer.toJson<String?>(trainType),
      'movementType': serializer.toJson<String?>(movementType),
      'scheduledDeparture': serializer.toJson<String?>(scheduledDeparture),
      'actualDeparture': serializer.toJson<String?>(actualDeparture),
      'primaryDepartment': serializer.toJson<String?>(primaryDepartment),
      'subReason': serializer.toJson<String?>(subReason),
      'crewTime': serializer.toJson<String?>(crewTime),
      'isExcluded': serializer.toJson<bool>(isExcluded),
      'pddMinutes': serializer.toJson<int>(pddMinutes),
      'crewTimeMinutes': serializer.toJson<int>(crewTimeMinutes),
    };
  }

  TrainRecordEntry copyWith(
          {int? id,
          DateTime? date,
          String? trainNumber,
          String? rollingStock,
          Value<String?> signOnTime = const Value.absent(),
          Value<String?> tocTime = const Value.absent(),
          Value<String?> readyTime = const Value.absent(),
          Value<String?> departureTime = const Value.absent(),
          Value<String?> locoDelay = const Value.absent(),
          Value<String?> cwDelay = const Value.absent(),
          Value<String?> trafficDelay = const Value.absent(),
          Value<String?> otherDelay = const Value.absent(),
          Value<String?> actualTimeTaken = const Value.absent(),
          Value<String?> remarks = const Value.absent(),
          String? status,
          String? pdd,
          Value<String?> direction = const Value.absent(),
          Value<String?> trainType = const Value.absent(),
          Value<String?> movementType = const Value.absent(),
          Value<String?> scheduledDeparture = const Value.absent(),
          Value<String?> actualDeparture = const Value.absent(),
          Value<String?> primaryDepartment = const Value.absent(),
          Value<String?> subReason = const Value.absent(),
          Value<String?> crewTime = const Value.absent(),
          bool? isExcluded,
          int? pddMinutes,
          int? crewTimeMinutes}) =>
      TrainRecordEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        trainNumber: trainNumber ?? this.trainNumber,
        rollingStock: rollingStock ?? this.rollingStock,
        signOnTime: signOnTime.present ? signOnTime.value : this.signOnTime,
        tocTime: tocTime.present ? tocTime.value : this.tocTime,
        readyTime: readyTime.present ? readyTime.value : this.readyTime,
        departureTime:
            departureTime.present ? departureTime.value : this.departureTime,
        locoDelay: locoDelay.present ? locoDelay.value : this.locoDelay,
        cwDelay: cwDelay.present ? cwDelay.value : this.cwDelay,
        trafficDelay:
            trafficDelay.present ? trafficDelay.value : this.trafficDelay,
        otherDelay: otherDelay.present ? otherDelay.value : this.otherDelay,
        actualTimeTaken: actualTimeTaken.present
            ? actualTimeTaken.value
            : this.actualTimeTaken,
        remarks: remarks.present ? remarks.value : this.remarks,
        status: status ?? this.status,
        pdd: pdd ?? this.pdd,
        direction: direction.present ? direction.value : this.direction,
        trainType: trainType.present ? trainType.value : this.trainType,
        movementType:
            movementType.present ? movementType.value : this.movementType,
        scheduledDeparture: scheduledDeparture.present
            ? scheduledDeparture.value
            : this.scheduledDeparture,
        actualDeparture: actualDeparture.present
            ? actualDeparture.value
            : this.actualDeparture,
        primaryDepartment: primaryDepartment.present
            ? primaryDepartment.value
            : this.primaryDepartment,
        subReason: subReason.present ? subReason.value : this.subReason,
        crewTime: crewTime.present ? crewTime.value : this.crewTime,
        isExcluded: isExcluded ?? this.isExcluded,
        pddMinutes: pddMinutes ?? this.pddMinutes,
        crewTimeMinutes: crewTimeMinutes ?? this.crewTimeMinutes,
      );
  TrainRecordEntry copyWithCompanion(TrainRecordEntriesCompanion data) {
    return TrainRecordEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      trainNumber:
          data.trainNumber.present ? data.trainNumber.value : this.trainNumber,
      rollingStock: data.rollingStock.present
          ? data.rollingStock.value
          : this.rollingStock,
      signOnTime:
          data.signOnTime.present ? data.signOnTime.value : this.signOnTime,
      tocTime: data.tocTime.present ? data.tocTime.value : this.tocTime,
      readyTime: data.readyTime.present ? data.readyTime.value : this.readyTime,
      departureTime: data.departureTime.present
          ? data.departureTime.value
          : this.departureTime,
      locoDelay: data.locoDelay.present ? data.locoDelay.value : this.locoDelay,
      cwDelay: data.cwDelay.present ? data.cwDelay.value : this.cwDelay,
      trafficDelay: data.trafficDelay.present
          ? data.trafficDelay.value
          : this.trafficDelay,
      otherDelay:
          data.otherDelay.present ? data.otherDelay.value : this.otherDelay,
      actualTimeTaken: data.actualTimeTaken.present
          ? data.actualTimeTaken.value
          : this.actualTimeTaken,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      status: data.status.present ? data.status.value : this.status,
      pdd: data.pdd.present ? data.pdd.value : this.pdd,
      direction: data.direction.present ? data.direction.value : this.direction,
      trainType: data.trainType.present ? data.trainType.value : this.trainType,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      scheduledDeparture: data.scheduledDeparture.present
          ? data.scheduledDeparture.value
          : this.scheduledDeparture,
      actualDeparture: data.actualDeparture.present
          ? data.actualDeparture.value
          : this.actualDeparture,
      primaryDepartment: data.primaryDepartment.present
          ? data.primaryDepartment.value
          : this.primaryDepartment,
      subReason: data.subReason.present ? data.subReason.value : this.subReason,
      crewTime: data.crewTime.present ? data.crewTime.value : this.crewTime,
      isExcluded:
          data.isExcluded.present ? data.isExcluded.value : this.isExcluded,
      pddMinutes:
          data.pddMinutes.present ? data.pddMinutes.value : this.pddMinutes,
      crewTimeMinutes: data.crewTimeMinutes.present
          ? data.crewTimeMinutes.value
          : this.crewTimeMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainRecordEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('trainNumber: $trainNumber, ')
          ..write('rollingStock: $rollingStock, ')
          ..write('signOnTime: $signOnTime, ')
          ..write('tocTime: $tocTime, ')
          ..write('readyTime: $readyTime, ')
          ..write('departureTime: $departureTime, ')
          ..write('locoDelay: $locoDelay, ')
          ..write('cwDelay: $cwDelay, ')
          ..write('trafficDelay: $trafficDelay, ')
          ..write('otherDelay: $otherDelay, ')
          ..write('actualTimeTaken: $actualTimeTaken, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
          ..write('pdd: $pdd, ')
          ..write('direction: $direction, ')
          ..write('trainType: $trainType, ')
          ..write('movementType: $movementType, ')
          ..write('scheduledDeparture: $scheduledDeparture, ')
          ..write('actualDeparture: $actualDeparture, ')
          ..write('primaryDepartment: $primaryDepartment, ')
          ..write('subReason: $subReason, ')
          ..write('crewTime: $crewTime, ')
          ..write('isExcluded: $isExcluded, ')
          ..write('pddMinutes: $pddMinutes, ')
          ..write('crewTimeMinutes: $crewTimeMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        date,
        trainNumber,
        rollingStock,
        signOnTime,
        tocTime,
        readyTime,
        departureTime,
        locoDelay,
        cwDelay,
        trafficDelay,
        otherDelay,
        actualTimeTaken,
        remarks,
        status,
        pdd,
        direction,
        trainType,
        movementType,
        scheduledDeparture,
        actualDeparture,
        primaryDepartment,
        subReason,
        crewTime,
        isExcluded,
        pddMinutes,
        crewTimeMinutes
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainRecordEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.trainNumber == this.trainNumber &&
          other.rollingStock == this.rollingStock &&
          other.signOnTime == this.signOnTime &&
          other.tocTime == this.tocTime &&
          other.readyTime == this.readyTime &&
          other.departureTime == this.departureTime &&
          other.locoDelay == this.locoDelay &&
          other.cwDelay == this.cwDelay &&
          other.trafficDelay == this.trafficDelay &&
          other.otherDelay == this.otherDelay &&
          other.actualTimeTaken == this.actualTimeTaken &&
          other.remarks == this.remarks &&
          other.status == this.status &&
          other.pdd == this.pdd &&
          other.direction == this.direction &&
          other.trainType == this.trainType &&
          other.movementType == this.movementType &&
          other.scheduledDeparture == this.scheduledDeparture &&
          other.actualDeparture == this.actualDeparture &&
          other.primaryDepartment == this.primaryDepartment &&
          other.subReason == this.subReason &&
          other.crewTime == this.crewTime &&
          other.isExcluded == this.isExcluded &&
          other.pddMinutes == this.pddMinutes &&
          other.crewTimeMinutes == this.crewTimeMinutes);
}

class TrainRecordEntriesCompanion extends UpdateCompanion<TrainRecordEntry> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> trainNumber;
  final Value<String> rollingStock;
  final Value<String?> signOnTime;
  final Value<String?> tocTime;
  final Value<String?> readyTime;
  final Value<String?> departureTime;
  final Value<String?> locoDelay;
  final Value<String?> cwDelay;
  final Value<String?> trafficDelay;
  final Value<String?> otherDelay;
  final Value<String?> actualTimeTaken;
  final Value<String?> remarks;
  final Value<String> status;
  final Value<String> pdd;
  final Value<String?> direction;
  final Value<String?> trainType;
  final Value<String?> movementType;
  final Value<String?> scheduledDeparture;
  final Value<String?> actualDeparture;
  final Value<String?> primaryDepartment;
  final Value<String?> subReason;
  final Value<String?> crewTime;
  final Value<bool> isExcluded;
  final Value<int> pddMinutes;
  final Value<int> crewTimeMinutes;
  const TrainRecordEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.trainNumber = const Value.absent(),
    this.rollingStock = const Value.absent(),
    this.signOnTime = const Value.absent(),
    this.tocTime = const Value.absent(),
    this.readyTime = const Value.absent(),
    this.departureTime = const Value.absent(),
    this.locoDelay = const Value.absent(),
    this.cwDelay = const Value.absent(),
    this.trafficDelay = const Value.absent(),
    this.otherDelay = const Value.absent(),
    this.actualTimeTaken = const Value.absent(),
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.pdd = const Value.absent(),
    this.direction = const Value.absent(),
    this.trainType = const Value.absent(),
    this.movementType = const Value.absent(),
    this.scheduledDeparture = const Value.absent(),
    this.actualDeparture = const Value.absent(),
    this.primaryDepartment = const Value.absent(),
    this.subReason = const Value.absent(),
    this.crewTime = const Value.absent(),
    this.isExcluded = const Value.absent(),
    this.pddMinutes = const Value.absent(),
    this.crewTimeMinutes = const Value.absent(),
  });
  TrainRecordEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String trainNumber,
    required String rollingStock,
    this.signOnTime = const Value.absent(),
    this.tocTime = const Value.absent(),
    this.readyTime = const Value.absent(),
    this.departureTime = const Value.absent(),
    this.locoDelay = const Value.absent(),
    this.cwDelay = const Value.absent(),
    this.trafficDelay = const Value.absent(),
    this.otherDelay = const Value.absent(),
    this.actualTimeTaken = const Value.absent(),
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.pdd = const Value.absent(),
    this.direction = const Value.absent(),
    this.trainType = const Value.absent(),
    this.movementType = const Value.absent(),
    this.scheduledDeparture = const Value.absent(),
    this.actualDeparture = const Value.absent(),
    this.primaryDepartment = const Value.absent(),
    this.subReason = const Value.absent(),
    this.crewTime = const Value.absent(),
    this.isExcluded = const Value.absent(),
    this.pddMinutes = const Value.absent(),
    this.crewTimeMinutes = const Value.absent(),
  })  : date = Value(date),
        trainNumber = Value(trainNumber),
        rollingStock = Value(rollingStock);
  static Insertable<TrainRecordEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? trainNumber,
    Expression<String>? rollingStock,
    Expression<String>? signOnTime,
    Expression<String>? tocTime,
    Expression<String>? readyTime,
    Expression<String>? departureTime,
    Expression<String>? locoDelay,
    Expression<String>? cwDelay,
    Expression<String>? trafficDelay,
    Expression<String>? otherDelay,
    Expression<String>? actualTimeTaken,
    Expression<String>? remarks,
    Expression<String>? status,
    Expression<String>? pdd,
    Expression<String>? direction,
    Expression<String>? trainType,
    Expression<String>? movementType,
    Expression<String>? scheduledDeparture,
    Expression<String>? actualDeparture,
    Expression<String>? primaryDepartment,
    Expression<String>? subReason,
    Expression<String>? crewTime,
    Expression<bool>? isExcluded,
    Expression<int>? pddMinutes,
    Expression<int>? crewTimeMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (trainNumber != null) 'train_number': trainNumber,
      if (rollingStock != null) 'rolling_stock': rollingStock,
      if (signOnTime != null) 'sign_on_time': signOnTime,
      if (tocTime != null) 'toc_time': tocTime,
      if (readyTime != null) 'ready_time': readyTime,
      if (departureTime != null) 'departure_time': departureTime,
      if (locoDelay != null) 'loco_delay': locoDelay,
      if (cwDelay != null) 'cw_delay': cwDelay,
      if (trafficDelay != null) 'traffic_delay': trafficDelay,
      if (otherDelay != null) 'other_delay': otherDelay,
      if (actualTimeTaken != null) 'actual_time_taken': actualTimeTaken,
      if (remarks != null) 'remarks': remarks,
      if (status != null) 'status': status,
      if (pdd != null) 'pdd': pdd,
      if (direction != null) 'direction': direction,
      if (trainType != null) 'train_type': trainType,
      if (movementType != null) 'movement_type': movementType,
      if (scheduledDeparture != null) 'scheduled_departure': scheduledDeparture,
      if (actualDeparture != null) 'actual_departure': actualDeparture,
      if (primaryDepartment != null) 'primary_department': primaryDepartment,
      if (subReason != null) 'sub_reason': subReason,
      if (crewTime != null) 'crew_time': crewTime,
      if (isExcluded != null) 'is_excluded': isExcluded,
      if (pddMinutes != null) 'pdd_minutes': pddMinutes,
      if (crewTimeMinutes != null) 'crew_time_minutes': crewTimeMinutes,
    });
  }

  TrainRecordEntriesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? trainNumber,
      Value<String>? rollingStock,
      Value<String?>? signOnTime,
      Value<String?>? tocTime,
      Value<String?>? readyTime,
      Value<String?>? departureTime,
      Value<String?>? locoDelay,
      Value<String?>? cwDelay,
      Value<String?>? trafficDelay,
      Value<String?>? otherDelay,
      Value<String?>? actualTimeTaken,
      Value<String?>? remarks,
      Value<String>? status,
      Value<String>? pdd,
      Value<String?>? direction,
      Value<String?>? trainType,
      Value<String?>? movementType,
      Value<String?>? scheduledDeparture,
      Value<String?>? actualDeparture,
      Value<String?>? primaryDepartment,
      Value<String?>? subReason,
      Value<String?>? crewTime,
      Value<bool>? isExcluded,
      Value<int>? pddMinutes,
      Value<int>? crewTimeMinutes}) {
    return TrainRecordEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      trainNumber: trainNumber ?? this.trainNumber,
      rollingStock: rollingStock ?? this.rollingStock,
      signOnTime: signOnTime ?? this.signOnTime,
      tocTime: tocTime ?? this.tocTime,
      readyTime: readyTime ?? this.readyTime,
      departureTime: departureTime ?? this.departureTime,
      locoDelay: locoDelay ?? this.locoDelay,
      cwDelay: cwDelay ?? this.cwDelay,
      trafficDelay: trafficDelay ?? this.trafficDelay,
      otherDelay: otherDelay ?? this.otherDelay,
      actualTimeTaken: actualTimeTaken ?? this.actualTimeTaken,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      pdd: pdd ?? this.pdd,
      direction: direction ?? this.direction,
      trainType: trainType ?? this.trainType,
      movementType: movementType ?? this.movementType,
      scheduledDeparture: scheduledDeparture ?? this.scheduledDeparture,
      actualDeparture: actualDeparture ?? this.actualDeparture,
      primaryDepartment: primaryDepartment ?? this.primaryDepartment,
      subReason: subReason ?? this.subReason,
      crewTime: crewTime ?? this.crewTime,
      isExcluded: isExcluded ?? this.isExcluded,
      pddMinutes: pddMinutes ?? this.pddMinutes,
      crewTimeMinutes: crewTimeMinutes ?? this.crewTimeMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (trainNumber.present) {
      map['train_number'] = Variable<String>(trainNumber.value);
    }
    if (rollingStock.present) {
      map['rolling_stock'] = Variable<String>(rollingStock.value);
    }
    if (signOnTime.present) {
      map['sign_on_time'] = Variable<String>(signOnTime.value);
    }
    if (tocTime.present) {
      map['toc_time'] = Variable<String>(tocTime.value);
    }
    if (readyTime.present) {
      map['ready_time'] = Variable<String>(readyTime.value);
    }
    if (departureTime.present) {
      map['departure_time'] = Variable<String>(departureTime.value);
    }
    if (locoDelay.present) {
      map['loco_delay'] = Variable<String>(locoDelay.value);
    }
    if (cwDelay.present) {
      map['cw_delay'] = Variable<String>(cwDelay.value);
    }
    if (trafficDelay.present) {
      map['traffic_delay'] = Variable<String>(trafficDelay.value);
    }
    if (otherDelay.present) {
      map['other_delay'] = Variable<String>(otherDelay.value);
    }
    if (actualTimeTaken.present) {
      map['actual_time_taken'] = Variable<String>(actualTimeTaken.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (pdd.present) {
      map['pdd'] = Variable<String>(pdd.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (trainType.present) {
      map['train_type'] = Variable<String>(trainType.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (scheduledDeparture.present) {
      map['scheduled_departure'] = Variable<String>(scheduledDeparture.value);
    }
    if (actualDeparture.present) {
      map['actual_departure'] = Variable<String>(actualDeparture.value);
    }
    if (primaryDepartment.present) {
      map['primary_department'] = Variable<String>(primaryDepartment.value);
    }
    if (subReason.present) {
      map['sub_reason'] = Variable<String>(subReason.value);
    }
    if (crewTime.present) {
      map['crew_time'] = Variable<String>(crewTime.value);
    }
    if (isExcluded.present) {
      map['is_excluded'] = Variable<bool>(isExcluded.value);
    }
    if (pddMinutes.present) {
      map['pdd_minutes'] = Variable<int>(pddMinutes.value);
    }
    if (crewTimeMinutes.present) {
      map['crew_time_minutes'] = Variable<int>(crewTimeMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainRecordEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('trainNumber: $trainNumber, ')
          ..write('rollingStock: $rollingStock, ')
          ..write('signOnTime: $signOnTime, ')
          ..write('tocTime: $tocTime, ')
          ..write('readyTime: $readyTime, ')
          ..write('departureTime: $departureTime, ')
          ..write('locoDelay: $locoDelay, ')
          ..write('cwDelay: $cwDelay, ')
          ..write('trafficDelay: $trafficDelay, ')
          ..write('otherDelay: $otherDelay, ')
          ..write('actualTimeTaken: $actualTimeTaken, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
          ..write('pdd: $pdd, ')
          ..write('direction: $direction, ')
          ..write('trainType: $trainType, ')
          ..write('movementType: $movementType, ')
          ..write('scheduledDeparture: $scheduledDeparture, ')
          ..write('actualDeparture: $actualDeparture, ')
          ..write('primaryDepartment: $primaryDepartment, ')
          ..write('subReason: $subReason, ')
          ..write('crewTime: $crewTime, ')
          ..write('isExcluded: $isExcluded, ')
          ..write('pddMinutes: $pddMinutes, ')
          ..write('crewTimeMinutes: $crewTimeMinutes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrainRecordEntriesTable trainRecordEntries =
      $TrainRecordEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [trainRecordEntries];
}

typedef $$TrainRecordEntriesTableCreateCompanionBuilder
    = TrainRecordEntriesCompanion Function({
  Value<int> id,
  required DateTime date,
  required String trainNumber,
  required String rollingStock,
  Value<String?> signOnTime,
  Value<String?> tocTime,
  Value<String?> readyTime,
  Value<String?> departureTime,
  Value<String?> locoDelay,
  Value<String?> cwDelay,
  Value<String?> trafficDelay,
  Value<String?> otherDelay,
  Value<String?> actualTimeTaken,
  Value<String?> remarks,
  Value<String> status,
  Value<String> pdd,
  Value<String?> direction,
  Value<String?> trainType,
  Value<String?> movementType,
  Value<String?> scheduledDeparture,
  Value<String?> actualDeparture,
  Value<String?> primaryDepartment,
  Value<String?> subReason,
  Value<String?> crewTime,
  Value<bool> isExcluded,
  Value<int> pddMinutes,
  Value<int> crewTimeMinutes,
});
typedef $$TrainRecordEntriesTableUpdateCompanionBuilder
    = TrainRecordEntriesCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> trainNumber,
  Value<String> rollingStock,
  Value<String?> signOnTime,
  Value<String?> tocTime,
  Value<String?> readyTime,
  Value<String?> departureTime,
  Value<String?> locoDelay,
  Value<String?> cwDelay,
  Value<String?> trafficDelay,
  Value<String?> otherDelay,
  Value<String?> actualTimeTaken,
  Value<String?> remarks,
  Value<String> status,
  Value<String> pdd,
  Value<String?> direction,
  Value<String?> trainType,
  Value<String?> movementType,
  Value<String?> scheduledDeparture,
  Value<String?> actualDeparture,
  Value<String?> primaryDepartment,
  Value<String?> subReason,
  Value<String?> crewTime,
  Value<bool> isExcluded,
  Value<int> pddMinutes,
  Value<int> crewTimeMinutes,
});

class $$TrainRecordEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TrainRecordEntriesTable> {
  $$TrainRecordEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trainNumber => $composableBuilder(
      column: $table.trainNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rollingStock => $composableBuilder(
      column: $table.rollingStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signOnTime => $composableBuilder(
      column: $table.signOnTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tocTime => $composableBuilder(
      column: $table.tocTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readyTime => $composableBuilder(
      column: $table.readyTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get departureTime => $composableBuilder(
      column: $table.departureTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locoDelay => $composableBuilder(
      column: $table.locoDelay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cwDelay => $composableBuilder(
      column: $table.cwDelay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trafficDelay => $composableBuilder(
      column: $table.trafficDelay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get otherDelay => $composableBuilder(
      column: $table.otherDelay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actualTimeTaken => $composableBuilder(
      column: $table.actualTimeTaken,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pdd => $composableBuilder(
      column: $table.pdd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trainType => $composableBuilder(
      column: $table.trainType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movementType => $composableBuilder(
      column: $table.movementType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduledDeparture => $composableBuilder(
      column: $table.scheduledDeparture,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actualDeparture => $composableBuilder(
      column: $table.actualDeparture,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primaryDepartment => $composableBuilder(
      column: $table.primaryDepartment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subReason => $composableBuilder(
      column: $table.subReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get crewTime => $composableBuilder(
      column: $table.crewTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isExcluded => $composableBuilder(
      column: $table.isExcluded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pddMinutes => $composableBuilder(
      column: $table.pddMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get crewTimeMinutes => $composableBuilder(
      column: $table.crewTimeMinutes,
      builder: (column) => ColumnFilters(column));
}

class $$TrainRecordEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainRecordEntriesTable> {
  $$TrainRecordEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trainNumber => $composableBuilder(
      column: $table.trainNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rollingStock => $composableBuilder(
      column: $table.rollingStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signOnTime => $composableBuilder(
      column: $table.signOnTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tocTime => $composableBuilder(
      column: $table.tocTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readyTime => $composableBuilder(
      column: $table.readyTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get departureTime => $composableBuilder(
      column: $table.departureTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locoDelay => $composableBuilder(
      column: $table.locoDelay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cwDelay => $composableBuilder(
      column: $table.cwDelay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trafficDelay => $composableBuilder(
      column: $table.trafficDelay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get otherDelay => $composableBuilder(
      column: $table.otherDelay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actualTimeTaken => $composableBuilder(
      column: $table.actualTimeTaken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pdd => $composableBuilder(
      column: $table.pdd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trainType => $composableBuilder(
      column: $table.trainType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movementType => $composableBuilder(
      column: $table.movementType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduledDeparture => $composableBuilder(
      column: $table.scheduledDeparture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actualDeparture => $composableBuilder(
      column: $table.actualDeparture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryDepartment => $composableBuilder(
      column: $table.primaryDepartment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subReason => $composableBuilder(
      column: $table.subReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get crewTime => $composableBuilder(
      column: $table.crewTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isExcluded => $composableBuilder(
      column: $table.isExcluded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pddMinutes => $composableBuilder(
      column: $table.pddMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get crewTimeMinutes => $composableBuilder(
      column: $table.crewTimeMinutes,
      builder: (column) => ColumnOrderings(column));
}

class $$TrainRecordEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainRecordEntriesTable> {
  $$TrainRecordEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get trainNumber => $composableBuilder(
      column: $table.trainNumber, builder: (column) => column);

  GeneratedColumn<String> get rollingStock => $composableBuilder(
      column: $table.rollingStock, builder: (column) => column);

  GeneratedColumn<String> get signOnTime => $composableBuilder(
      column: $table.signOnTime, builder: (column) => column);

  GeneratedColumn<String> get tocTime =>
      $composableBuilder(column: $table.tocTime, builder: (column) => column);

  GeneratedColumn<String> get readyTime =>
      $composableBuilder(column: $table.readyTime, builder: (column) => column);

  GeneratedColumn<String> get departureTime => $composableBuilder(
      column: $table.departureTime, builder: (column) => column);

  GeneratedColumn<String> get locoDelay =>
      $composableBuilder(column: $table.locoDelay, builder: (column) => column);

  GeneratedColumn<String> get cwDelay =>
      $composableBuilder(column: $table.cwDelay, builder: (column) => column);

  GeneratedColumn<String> get trafficDelay => $composableBuilder(
      column: $table.trafficDelay, builder: (column) => column);

  GeneratedColumn<String> get otherDelay => $composableBuilder(
      column: $table.otherDelay, builder: (column) => column);

  GeneratedColumn<String> get actualTimeTaken => $composableBuilder(
      column: $table.actualTimeTaken, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get pdd =>
      $composableBuilder(column: $table.pdd, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get trainType =>
      $composableBuilder(column: $table.trainType, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
      column: $table.movementType, builder: (column) => column);

  GeneratedColumn<String> get scheduledDeparture => $composableBuilder(
      column: $table.scheduledDeparture, builder: (column) => column);

  GeneratedColumn<String> get actualDeparture => $composableBuilder(
      column: $table.actualDeparture, builder: (column) => column);

  GeneratedColumn<String> get primaryDepartment => $composableBuilder(
      column: $table.primaryDepartment, builder: (column) => column);

  GeneratedColumn<String> get subReason =>
      $composableBuilder(column: $table.subReason, builder: (column) => column);

  GeneratedColumn<String> get crewTime =>
      $composableBuilder(column: $table.crewTime, builder: (column) => column);

  GeneratedColumn<bool> get isExcluded => $composableBuilder(
      column: $table.isExcluded, builder: (column) => column);

  GeneratedColumn<int> get pddMinutes => $composableBuilder(
      column: $table.pddMinutes, builder: (column) => column);

  GeneratedColumn<int> get crewTimeMinutes => $composableBuilder(
      column: $table.crewTimeMinutes, builder: (column) => column);
}

class $$TrainRecordEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrainRecordEntriesTable,
    TrainRecordEntry,
    $$TrainRecordEntriesTableFilterComposer,
    $$TrainRecordEntriesTableOrderingComposer,
    $$TrainRecordEntriesTableAnnotationComposer,
    $$TrainRecordEntriesTableCreateCompanionBuilder,
    $$TrainRecordEntriesTableUpdateCompanionBuilder,
    (
      TrainRecordEntry,
      BaseReferences<_$AppDatabase, $TrainRecordEntriesTable, TrainRecordEntry>
    ),
    TrainRecordEntry,
    PrefetchHooks Function()> {
  $$TrainRecordEntriesTableTableManager(
      _$AppDatabase db, $TrainRecordEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainRecordEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainRecordEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainRecordEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> trainNumber = const Value.absent(),
            Value<String> rollingStock = const Value.absent(),
            Value<String?> signOnTime = const Value.absent(),
            Value<String?> tocTime = const Value.absent(),
            Value<String?> readyTime = const Value.absent(),
            Value<String?> departureTime = const Value.absent(),
            Value<String?> locoDelay = const Value.absent(),
            Value<String?> cwDelay = const Value.absent(),
            Value<String?> trafficDelay = const Value.absent(),
            Value<String?> otherDelay = const Value.absent(),
            Value<String?> actualTimeTaken = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> pdd = const Value.absent(),
            Value<String?> direction = const Value.absent(),
            Value<String?> trainType = const Value.absent(),
            Value<String?> movementType = const Value.absent(),
            Value<String?> scheduledDeparture = const Value.absent(),
            Value<String?> actualDeparture = const Value.absent(),
            Value<String?> primaryDepartment = const Value.absent(),
            Value<String?> subReason = const Value.absent(),
            Value<String?> crewTime = const Value.absent(),
            Value<bool> isExcluded = const Value.absent(),
            Value<int> pddMinutes = const Value.absent(),
            Value<int> crewTimeMinutes = const Value.absent(),
          }) =>
              TrainRecordEntriesCompanion(
            id: id,
            date: date,
            trainNumber: trainNumber,
            rollingStock: rollingStock,
            signOnTime: signOnTime,
            tocTime: tocTime,
            readyTime: readyTime,
            departureTime: departureTime,
            locoDelay: locoDelay,
            cwDelay: cwDelay,
            trafficDelay: trafficDelay,
            otherDelay: otherDelay,
            actualTimeTaken: actualTimeTaken,
            remarks: remarks,
            status: status,
            pdd: pdd,
            direction: direction,
            trainType: trainType,
            movementType: movementType,
            scheduledDeparture: scheduledDeparture,
            actualDeparture: actualDeparture,
            primaryDepartment: primaryDepartment,
            subReason: subReason,
            crewTime: crewTime,
            isExcluded: isExcluded,
            pddMinutes: pddMinutes,
            crewTimeMinutes: crewTimeMinutes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required String trainNumber,
            required String rollingStock,
            Value<String?> signOnTime = const Value.absent(),
            Value<String?> tocTime = const Value.absent(),
            Value<String?> readyTime = const Value.absent(),
            Value<String?> departureTime = const Value.absent(),
            Value<String?> locoDelay = const Value.absent(),
            Value<String?> cwDelay = const Value.absent(),
            Value<String?> trafficDelay = const Value.absent(),
            Value<String?> otherDelay = const Value.absent(),
            Value<String?> actualTimeTaken = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> pdd = const Value.absent(),
            Value<String?> direction = const Value.absent(),
            Value<String?> trainType = const Value.absent(),
            Value<String?> movementType = const Value.absent(),
            Value<String?> scheduledDeparture = const Value.absent(),
            Value<String?> actualDeparture = const Value.absent(),
            Value<String?> primaryDepartment = const Value.absent(),
            Value<String?> subReason = const Value.absent(),
            Value<String?> crewTime = const Value.absent(),
            Value<bool> isExcluded = const Value.absent(),
            Value<int> pddMinutes = const Value.absent(),
            Value<int> crewTimeMinutes = const Value.absent(),
          }) =>
              TrainRecordEntriesCompanion.insert(
            id: id,
            date: date,
            trainNumber: trainNumber,
            rollingStock: rollingStock,
            signOnTime: signOnTime,
            tocTime: tocTime,
            readyTime: readyTime,
            departureTime: departureTime,
            locoDelay: locoDelay,
            cwDelay: cwDelay,
            trafficDelay: trafficDelay,
            otherDelay: otherDelay,
            actualTimeTaken: actualTimeTaken,
            remarks: remarks,
            status: status,
            pdd: pdd,
            direction: direction,
            trainType: trainType,
            movementType: movementType,
            scheduledDeparture: scheduledDeparture,
            actualDeparture: actualDeparture,
            primaryDepartment: primaryDepartment,
            subReason: subReason,
            crewTime: crewTime,
            isExcluded: isExcluded,
            pddMinutes: pddMinutes,
            crewTimeMinutes: crewTimeMinutes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrainRecordEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrainRecordEntriesTable,
    TrainRecordEntry,
    $$TrainRecordEntriesTableFilterComposer,
    $$TrainRecordEntriesTableOrderingComposer,
    $$TrainRecordEntriesTableAnnotationComposer,
    $$TrainRecordEntriesTableCreateCompanionBuilder,
    $$TrainRecordEntriesTableUpdateCompanionBuilder,
    (
      TrainRecordEntry,
      BaseReferences<_$AppDatabase, $TrainRecordEntriesTable, TrainRecordEntry>
    ),
    TrainRecordEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrainRecordEntriesTableTableManager get trainRecordEntries =>
      $$TrainRecordEntriesTableTableManager(_db, _db.trainRecordEntries);
}
