import 'dart:io';

import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:realm/realm.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/utils/bytes.dart';

part 'training_report.g.dart';

enum ReportStatus {
  notReported,
  reported,
  expired,
  failed,
}

extension ReportStatusExtension on ReportStatus {

  String get display {
    switch (this) {
      case ReportStatus.notReported:
        return 'Can Report';
      case ReportStatus.reported:
        return 'Reported';
      case ReportStatus.expired:
        return 'Expired';
      case ReportStatus.failed:
        return 'Failed';
    }
  }
  String get image {
    switch (this) {
      case ReportStatus.notReported:
        return 'assets/images/icon-dd.png';
      case ReportStatus.reported:
        return 'assets/images/icon-ytj.png';
      case ReportStatus.expired:
        return 'assets/images/icon-wtj.png';
      case ReportStatus.failed:
        return 'assets/images/icon-wtj.png';
    }
  }
}

class TrainingDisplay {
  int mode = 0; //跳绳模式
  int setting = 0; //跳绳设置
  int trainingDuration = 0; //跳绳总时长
  int totalJumpRopeCount = 0; //跳绳总次数
  int batteryPercent = 0; //平均频次
  int jumpRopeDuration = 0; //有效跳绳时长

  TrainingDisplay.fromJson(Map<String, dynamic> json)
      : mode = json['mode'],
        setting = json['setting'],
        trainingDuration = json['skipSecSum'],
        totalJumpRopeCount = json['skipCntSum'],
        batteryPercent = json['batteryPercent'],
        jumpRopeDuration = json['skipValidSec'];

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'setting': setting,
        'skipSecSum': trainingDuration,
        'skipCntSum': totalJumpRopeCount,
        'batteryPercent': batteryPercent,
        'skipValidSec': jumpRopeDuration,
      };
}

@RealmModel()
class _TrainingReport {
  @PrimaryKey()
  late ObjectId id;

  /*
    {
        'messageType': '2',
        'messageContext': {
            'timestamp': '1667966002',  //时间戳
            'skipSecSum': '11', //跳绳总时长
            'skipCntSum': '40', //跳绳总次数
            'skipValidSec': '11', //有效跳绳时长
            'freqAvg': '218', //平均频次
            'freqMax': '260', //最快频次
            'consecutiveSkipMaxNum': '13', //最大连跳次数
            'skipTripNum': '3', //绊绳次数
            'signature': '21f7a9272057cb1ced5bbd6b81ae4261e236ec5f260562de1cceb490576656ba6348b5725a0968057e470436e901a603033fdc4662b21bf6617c0a199a9da7a4'
        }
    }
   */

  late int reportTime = 0; //时间戳
  late int trainingDuration = 0; //跳绳总时长
  late int totalJumpRopeCount = 0; //跳绳总次数
  late int averageSpeed = 0; //平均频次
  late int maxSpeed = 0; //最快频次
  late int maxJumpRopeCount = 0; //最大连跳次数
  late int interruptions = 0; //绊绳次数
  late int jumpRopeDuration = 0; //有效跳绳时长
  late String status = '';
  late String signature = '';
  late String deviceKey = '';
  late String error = '';

  late _TrainingReward? reward;

  String encodeData() {
    final data = BytesBuilder();
    data.add(int32Bytes(reportTime, Endian.little)); // 4 bytes
    data.add(int16Bytes(trainingDuration, Endian.little)); // 2 bytes
    data.add(int16Bytes(totalJumpRopeCount, Endian.little)); // 2 bytes
    data.add(int16Bytes(averageSpeed, Endian.little)); // 2 bytes
    data.add(int16Bytes(maxSpeed, Endian.little)); // 2 bytes
    data.add(int16Bytes(maxJumpRopeCount, Endian.little)); // 2 bytes
    data.add(int8Bytes(interruptions)); // 1 bytes
    data.add(int16Bytes(jumpRopeDuration, Endian.little)); // 2 bytes
    return hex.encode(data.toBytes());
  }
  
  ReportStatus reportStatus(int now) {
    ReportStatus reportStatus = ReportStatus.notReported;
    if (status.isEmpty) {
      return ReportStatus.notReported;
    }
    reportStatus = ReportStatus.values.byName(status);
    return reportStatus;
  }
}

TrainingReport newTrainingReportFromJson(Map<String, dynamic> json) {
  int reportTime = json['timestamp'];
  int trainingDuration = json['skipSecSum'];
  int totalJumpRopeCount = json['skipCntSum'];
  int averageSpeed = json['freqAvg'];
  int maxSpeed = json['freqMax'];
  int maxJumpRopeCount = json['consecutiveSkipMaxNum'];
  int interruptions = json['skipTripNum'];
  int jumpRopeDuration = json['skipValidSec'];
  String status = json['status'] ?? 'notReported';
  String signature = json['signature'];
  String deviceKey = json['deviceKey'] ?? '';

  final data = TrainingReport(
    ObjectId(),
    reportTime: reportTime,
    trainingDuration: trainingDuration,
    totalJumpRopeCount: totalJumpRopeCount,
    averageSpeed: averageSpeed,
    maxSpeed: maxSpeed,
    maxJumpRopeCount: maxJumpRopeCount,
    interruptions: interruptions,
    jumpRopeDuration: jumpRopeDuration,
    status: status,
    signature: signature,
    deviceKey: deviceKey,
  );
  return data;
}

@RealmModel()
class _TrainingReward {
  @PrimaryKey()
  late ObjectId id;

  late int energyUsed = 0;
  late int batteryUsed = 0;
  late String rewards = '0';
  late int assetId = 0;
}

TrainingReward newTrainingRewardFromJson(Map<String, dynamic> json) {
  int energyUsed = json['energyUsed'] ?? 0;
  int batteryUsed = json['batteryUsed'] ?? 0;
  String rewards = json['rewards'] ?? '0';
  int assetId = json['assetId'] ?? 0;
  final data = TrainingReward(
    ObjectId(),
    energyUsed: energyUsed,
    batteryUsed: batteryUsed,
    rewards: rewards,
    assetId: assetId,
  );
  return data;
}
