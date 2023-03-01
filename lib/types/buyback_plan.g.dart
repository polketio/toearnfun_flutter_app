// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyback_plan.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class BuyBackPlan extends _BuyBackPlan
    with RealmEntity, RealmObjectBase, RealmObject {
  BuyBackPlan(
    int id,
    int sellAssetId,
    int buyAssetId,
    String status,
    String minSell,
    int start,
    int period,
    String totalSell,
    String totalBuy,
    int sellerAmount,
    int sellerLimit,
    String creator,
    String mode,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'sellAssetId', sellAssetId);
    RealmObjectBase.set(this, 'buyAssetId', buyAssetId);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'minSell', minSell);
    RealmObjectBase.set(this, 'start', start);
    RealmObjectBase.set(this, 'period', period);
    RealmObjectBase.set(this, 'totalSell', totalSell);
    RealmObjectBase.set(this, 'totalBuy', totalBuy);
    RealmObjectBase.set(this, 'sellerAmount', sellerAmount);
    RealmObjectBase.set(this, 'sellerLimit', sellerLimit);
    RealmObjectBase.set(this, 'creator', creator);
    RealmObjectBase.set(this, 'mode', mode);
  }

  BuyBackPlan._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => throw RealmUnsupportedSetError();

  @override
  int get sellAssetId => RealmObjectBase.get<int>(this, 'sellAssetId') as int;
  @override
  set sellAssetId(int value) => RealmObjectBase.set(this, 'sellAssetId', value);

  @override
  int get buyAssetId => RealmObjectBase.get<int>(this, 'buyAssetId') as int;
  @override
  set buyAssetId(int value) => RealmObjectBase.set(this, 'buyAssetId', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  String get minSell => RealmObjectBase.get<String>(this, 'minSell') as String;
  @override
  set minSell(String value) => RealmObjectBase.set(this, 'minSell', value);

  @override
  int get start => RealmObjectBase.get<int>(this, 'start') as int;
  @override
  set start(int value) => RealmObjectBase.set(this, 'start', value);

  @override
  int get period => RealmObjectBase.get<int>(this, 'period') as int;
  @override
  set period(int value) => RealmObjectBase.set(this, 'period', value);

  @override
  String get totalSell =>
      RealmObjectBase.get<String>(this, 'totalSell') as String;
  @override
  set totalSell(String value) => RealmObjectBase.set(this, 'totalSell', value);

  @override
  String get totalBuy =>
      RealmObjectBase.get<String>(this, 'totalBuy') as String;
  @override
  set totalBuy(String value) => RealmObjectBase.set(this, 'totalBuy', value);

  @override
  int get sellerAmount => RealmObjectBase.get<int>(this, 'sellerAmount') as int;
  @override
  set sellerAmount(int value) =>
      RealmObjectBase.set(this, 'sellerAmount', value);

  @override
  int get sellerLimit => RealmObjectBase.get<int>(this, 'sellerLimit') as int;
  @override
  set sellerLimit(int value) => RealmObjectBase.set(this, 'sellerLimit', value);

  @override
  String get creator => RealmObjectBase.get<String>(this, 'creator') as String;
  @override
  set creator(String value) => RealmObjectBase.set(this, 'creator', value);

  @override
  String get mode => RealmObjectBase.get<String>(this, 'mode') as String;
  @override
  set mode(String value) => RealmObjectBase.set(this, 'mode', value);

  @override
  Stream<RealmObjectChanges<BuyBackPlan>> get changes =>
      RealmObjectBase.getChanges<BuyBackPlan>(this);

  @override
  BuyBackPlan freeze() => RealmObjectBase.freezeObject<BuyBackPlan>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(BuyBackPlan._);
    return const SchemaObject(
        ObjectType.realmObject, BuyBackPlan, 'BuyBackPlan', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('sellAssetId', RealmPropertyType.int),
      SchemaProperty('buyAssetId', RealmPropertyType.int),
      SchemaProperty('status', RealmPropertyType.string),
      SchemaProperty('minSell', RealmPropertyType.string),
      SchemaProperty('start', RealmPropertyType.int),
      SchemaProperty('period', RealmPropertyType.int),
      SchemaProperty('totalSell', RealmPropertyType.string),
      SchemaProperty('totalBuy', RealmPropertyType.string),
      SchemaProperty('sellerAmount', RealmPropertyType.int),
      SchemaProperty('sellerLimit', RealmPropertyType.int),
      SchemaProperty('creator', RealmPropertyType.string),
      SchemaProperty('mode', RealmPropertyType.string),
    ]);
  }
}
