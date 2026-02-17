// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainRecord _$TrainRecordFromJson(Map<String, dynamic> json) => TrainRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      trainNumber: json['trainNumber'] as String,
      rollingStock: json['rollingStock'] as String,
      signOnTime: json['signOnTime'] as String?,
      tocTime: json['tocTime'] as String?,
      readyTime: json['readyTime'] as String?,
      departureTime: json['departureTime'] as String?,
      locoDelay: json['locoDelay'] as String?,
      cwDelay: json['cwDelay'] as String?,
      trafficDelay: json['trafficDelay'] as String?,
      otherDelay: json['otherDelay'] as String?,
      actualTimeTaken: json['actualTimeTaken'] as String?,
      remarks: json['remarks'] as String?,
      status: json['status'] as String? ?? 'In Progress',
      status: json['status'] as String? ?? 'In Progress',
      pdd: json['pdd'] as String? ?? '0:00',
      direction: json['direction'] as String?,
      trainType: json['trainType'] as String?,
      movementType: json['movementType'] as String?,
      scheduledDeparture: json['scheduledDeparture'] as String?,
      actualDeparture: json['actualDeparture'] as String?,
      primaryDepartment: json['primaryDepartment'] as String?,
      subReason: json['subReason'] as String?,
      crewTime: json['crewTime'] as String?,
      isExcluded: json['isExcluded'] as bool? ?? false,
    );

Map<String, dynamic> _$TrainRecordToJson(TrainRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'trainNumber': instance.trainNumber,
      'rollingStock': instance.rollingStock,
      'signOnTime': instance.signOnTime,
      'tocTime': instance.tocTime,
      'readyTime': instance.readyTime,
      'departureTime': instance.departureTime,
      'locoDelay': instance.locoDelay,
      'cwDelay': instance.cwDelay,
      'trafficDelay': instance.trafficDelay,
      'otherDelay': instance.otherDelay,
      'actualTimeTaken': instance.actualTimeTaken,
      'remarks': instance.remarks,
      'status': instance.status,
      'pdd': instance.pdd,
      'direction': instance.direction,
      'trainType': instance.trainType,
      'movementType': instance.movementType,
      'scheduledDeparture': instance.scheduledDeparture,
      'actualDeparture': instance.actualDeparture,
      'primaryDepartment': instance.primaryDepartment,
      'subReason': instance.subReason,
      'crewTime': instance.crewTime,
      'isExcluded': instance.isExcluded,
    };
