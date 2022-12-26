// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_report.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class TrainingReport extends _TrainingReport
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TrainingReport(
    ObjectId id, {
    int reportTime = 0,
    int trainingDuration = 0,
    int totalJumpRopeCount = 0,
    int averageSpeed = 0,
    int maxSpeed = 0,
    int maxJumpRopeCount = 0,
    int interruptions = 0,
    int jumpRopeDuration = 0,
    String status = '',
    String signature = '',
    String deviceKey = '',
    String error = '',
    TrainingReward? reward,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TrainingReport>({
        'reportTime': 0,
        'trainingDuration': 0,
        'totalJumpRopeCount': 0,
        'averageSpeed': 0,
        'maxSpeed': 0,
        'maxJumpRopeCount': 0,
        'interruptions': 0,
        'jumpRopeDuration': 0,
        'status': '',
        'signature': '',
        'deviceKey': '',
        'error': '',
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'reportTime', reportTime);
    RealmObjectBase.set(this, 'trainingDuration', trainingDuration);
    RealmObjectBase.set(this, 'totalJumpRopeCount', totalJumpRopeCount);
    RealmObjectBase.set(this, 'averageSpeed', averageSpeed);
    RealmObjectBase.set(this, 'maxSpeed', maxSpeed);
    RealmObjectBase.set(this, 'maxJumpRopeCount', maxJumpRopeCount);
    RealmObjectBase.set(this, 'interruptions', interruptions);
    RealmObjectBase.set(this, 'jumpRopeDuration', jumpRopeDuration);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'signature', signature);
    RealmObjectBase.set(this, 'deviceKey', deviceKey);
    RealmObjectBase.set(this, 'error', error);
    RealmObjectBase.set(this, 'reward', reward);
  }

  TrainingReport._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get reportTime => RealmObjectBase.get<int>(this, 'reportTime') as int;
  @override
  set reportTime(int value) => RealmObjectBase.set(this, 'reportTime', value);

  @override
  int get trainingDuration =>
      RealmObjectBase.get<int>(this, 'trainingDuration') as int;
  @override
  set trainingDuration(int value) =>
      RealmObjectBase.set(this, 'trainingDuration', value);

  @override
  int get totalJumpRopeCount =>
      RealmObjectBase.get<int>(this, 'totalJumpRopeCount') as int;
  @override
  set totalJumpRopeCount(int value) =>
      RealmObjectBase.set(this, 'totalJumpRopeCount', value);

  @override
  int get averageSpeed => RealmObjectBase.get<int>(this, 'averageSpeed') as int;
  @override
  set averageSpeed(int value) =>
      RealmObjectBase.set(this, 'averageSpeed', value);

  @override
  int get maxSpeed => RealmObjectBase.get<int>(this, 'maxSpeed') as int;
  @override
  set maxSpeed(int value) => RealmObjectBase.set(this, 'maxSpeed', value);

  @override
  int get maxJumpRopeCount =>
      RealmObjectBase.get<int>(this, 'maxJumpRopeCount') as int;
  @override
  set maxJumpRopeCount(int value) =>
      RealmObjectBase.set(this, 'maxJumpRopeCount', value);

  @override
  int get interruptions =>
      RealmObjectBase.get<int>(this, 'interruptions') as int;
  @override
  set interruptions(int value) =>
      RealmObjectBase.set(this, 'interruptions', value);

  @override
  int get jumpRopeDuration =>
      RealmObjectBase.get<int>(this, 'jumpRopeDuration') as int;
  @override
  set jumpRopeDuration(int value) =>
      RealmObjectBase.set(this, 'jumpRopeDuration', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  String get signature =>
      RealmObjectBase.get<String>(this, 'signature') as String;
  @override
  set signature(String value) => RealmObjectBase.set(this, 'signature', value);

  @override
  String get deviceKey =>
      RealmObjectBase.get<String>(this, 'deviceKey') as String;
  @override
  set deviceKey(String value) => RealmObjectBase.set(this, 'deviceKey', value);

  @override
  String get error => RealmObjectBase.get<String>(this, 'error') as String;
  @override
  set error(String value) => RealmObjectBase.set(this, 'error', value);

  @override
  TrainingReward? get reward =>
      RealmObjectBase.get<TrainingReward>(this, 'reward') as TrainingReward?;
  @override
  set reward(covariant TrainingReward? value) =>
      RealmObjectBase.set(this, 'reward', value);

  @override
  Stream<RealmObjectChanges<TrainingReport>> get changes =>
      RealmObjectBase.getChanges<TrainingReport>(this);

  @override
  TrainingReport freeze() => RealmObjectBase.freezeObject<TrainingReport>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TrainingReport._);
    return const SchemaObject(
        ObjectType.realmObject, TrainingReport, 'TrainingReport', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('reportTime', RealmPropertyType.int),
      SchemaProperty('trainingDuration', RealmPropertyType.int),
      SchemaProperty('totalJumpRopeCount', RealmPropertyType.int),
      SchemaProperty('averageSpeed', RealmPropertyType.int),
      SchemaProperty('maxSpeed', RealmPropertyType.int),
      SchemaProperty('maxJumpRopeCount', RealmPropertyType.int),
      SchemaProperty('interruptions', RealmPropertyType.int),
      SchemaProperty('jumpRopeDuration', RealmPropertyType.int),
      SchemaProperty('status', RealmPropertyType.string),
      SchemaProperty('signature', RealmPropertyType.string),
      SchemaProperty('deviceKey', RealmPropertyType.string),
      SchemaProperty('error', RealmPropertyType.string),
      SchemaProperty('reward', RealmPropertyType.object,
          optional: true, linkTarget: 'TrainingReward'),
    ]);
  }
}

class TrainingReward extends _TrainingReward
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TrainingReward(
    ObjectId id, {
    int energyUsed = 0,
    int batteryUsed = 0,
    String rewards = '0',
    int assetId = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TrainingReward>({
        'energyUsed': 0,
        'batteryUsed': 0,
        'rewards': '0',
        'assetId': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'energyUsed', energyUsed);
    RealmObjectBase.set(this, 'batteryUsed', batteryUsed);
    RealmObjectBase.set(this, 'rewards', rewards);
    RealmObjectBase.set(this, 'assetId', assetId);
  }

  TrainingReward._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get energyUsed => RealmObjectBase.get<int>(this, 'energyUsed') as int;
  @override
  set energyUsed(int value) => RealmObjectBase.set(this, 'energyUsed', value);

  @override
  int get batteryUsed => RealmObjectBase.get<int>(this, 'batteryUsed') as int;
  @override
  set batteryUsed(int value) => RealmObjectBase.set(this, 'batteryUsed', value);

  @override
  String get rewards => RealmObjectBase.get<String>(this, 'rewards') as String;
  @override
  set rewards(String value) => RealmObjectBase.set(this, 'rewards', value);

  @override
  int get assetId => RealmObjectBase.get<int>(this, 'assetId') as int;
  @override
  set assetId(int value) => RealmObjectBase.set(this, 'assetId', value);

  @override
  Stream<RealmObjectChanges<TrainingReward>> get changes =>
      RealmObjectBase.getChanges<TrainingReward>(this);

  @override
  TrainingReward freeze() => RealmObjectBase.freezeObject<TrainingReward>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TrainingReward._);
    return const SchemaObject(
        ObjectType.realmObject, TrainingReward, 'TrainingReward', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('energyUsed', RealmPropertyType.int),
      SchemaProperty('batteryUsed', RealmPropertyType.int),
      SchemaProperty('rewards', RealmPropertyType.string),
      SchemaProperty('assetId', RealmPropertyType.int),
    ]);
  }
}
