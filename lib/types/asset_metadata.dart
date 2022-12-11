

class AssetMetadata extends _AssetMetadata {
  static AssetMetadata fromJson(Map json) {
    final data = AssetMetadata();
    data.assetId = json['assetId'];
    data.deposit = json['deposit'].toString();
    data.name = json['name'];
    data.decimals = json['decimals'];
    data.isFrozen = json['isFrozen'];
    return data;
  }
}

abstract class _AssetMetadata {
  String? assetId;
  String? deposit;
  String? name;
  int? decimals;
  bool? isFrozen;
}


class MintCost {
  int assetId;
  String cost;
  MintCost(this.assetId, this.cost);

  MintCost.fromJson(Map<String, dynamic> json)
      : assetId = json['assetId'] ?? 0,
        cost = json['mac'] ?? '';

  Map<String, dynamic> toJson() => {
    'assetId': assetId,
    'cost': cost,
  };
}