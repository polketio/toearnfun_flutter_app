import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

class VFEBrand {
  int? brandId;
  SportType? sportType;
  VFERarity? rarity;
  String uri = "";

  VFEBrand.fromJson(Map<String, dynamic> json)
      : brandId = json['brandId'] ?? 0,
        sportType = SportType.values.byName(json['sportType'] ?? "JumpRope"),
        rarity = VFERarity.values.byName(json['rarity'] ?? "Common"),
        uri = json['uri'] ?? "";

  Map<String, dynamic> toJson() => {
        'brandId': brandId,
        'sportType': sportType?.name,
        'rarity': rarity?.name,
        'uri': uri,
      };
}

enum SportType {
  JumpRope,
  Run,
  Bicycle,
}
