

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
