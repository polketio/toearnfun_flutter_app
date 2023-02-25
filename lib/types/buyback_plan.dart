import 'package:realm/realm.dart';

part 'buyback_plan.g.dart';

@RealmModel()
class _BuyBackPlan {
  @PrimaryKey()
  late final int id;

  late int sellAssetId;
  late int buyAssetId;
  late String status;
  late String minSell;
  late int start;
  late int period;
  late String totalSell;
  late String totalBuy;
  late int sellerAmount;
  late int sellerLimit;
  late String creator;
  late String mode;
}

extension BuybackPlanJson on BuyBackPlan {

  static BuyBackPlan toRealmObject(_BuyBackPlan obj) {
    return BuyBackPlan(
      obj.id,
      obj.sellAssetId,
      obj.buyAssetId,
      obj.status,
      obj.minSell,
      obj.start,
      obj.period,
      obj.totalSell,
      obj.totalBuy,
      obj.sellerAmount,
      obj.sellerLimit,
      obj.creator,
      obj.mode,
    );
  }

  static BuyBackPlan fromJson(Map<String, dynamic> json) {
    _BuyBackPlan obj = _BuyBackPlan();
    obj.id = json['id'];
    obj.sellAssetId = json['sellAssetId'];
    obj.buyAssetId = json['buyAssetId'];
    obj.status = json['status'];
    obj.minSell = json['minSell'].toString();
    obj.start = json['start'];
    obj.period = json['period'];
    obj.totalSell = json['totalSell'].toString();
    obj.totalBuy = json['totalBuy'].toString();
    obj.sellerAmount = json['sellerAmount'];
    obj.sellerLimit = json['sellerLimit'];
    obj.creator = json['creator'];
    obj.mode = json['mode'];
    return toRealmObject(obj);
  }
}

enum PlanStatus {
  /// Waiting for startup
  Upcoming,

  /// Plan is in progress, sellers can lock asset in it.
  InProgress,

  /// Plan is Completed, sellers can withdraw rewards.
  Completed,

  /// All rewards has been paybacked.
  AllPaybacked,
}

enum BuybackMode {
  /// Burn
  Burn,

  /// Transfer
  Transfer,
}
