class VFEDetail {
  int? brandId;
  int? itemId;
  String? owner;
  VFEAbility baseAbility = VFEAbility();
  VFEAbility currentAbility = VFEAbility();
  VFERarity rarity = VFERarity.Common;
  int level = 0;
  int remainingBattery = 0;
  String? gene;
  bool isUpgrading = false;
  int lastBlock = 0;
  int availablePoints = 0;

  VFEDetail.fromJson(Map<String, dynamic> json)
      : brandId = json['brandId'] ?? 0,
        itemId = json['itemId'] ?? 0,
        owner = json['owner'] ?? "",
        rarity =  VFERarity.values.byName(json['rarity'] ?? "Common"),
        level = json['level'] ?? 0,
        remainingBattery = json['remainingBattery'] ?? 0,
        gene = json['gene'] ?? "",
        isUpgrading = json['isUpgrading'] ?? false,
        lastBlock = json['lastBlock'] ?? 0,
        availablePoints = json['availablePoints'] ?? 0,
        baseAbility = VFEAbility.fromJson(json['baseAbility']),
        currentAbility = VFEAbility.fromJson(json['currentAbility']);

  Map<String, dynamic> toJson() => {
    'brandId': brandId,
    'itemId': itemId,
    'owner': owner,
    'rarity': rarity,
    'level': level,
    'remainingBattery': remainingBattery,
    'gene': gene,
    'isUpgrading': isUpgrading,
    'lastBlock': lastBlock,
    'availablePoints': availablePoints,
    'baseAbility': baseAbility.toJson(),
    'currentAbility': currentAbility.toJson(),
  };

}

class VFEAbility {
  int efficiency = 0;
  int skill = 0;
  int luck = 0;
  int durable = 0;

  VFEAbility();

  VFEAbility.fromJson(Map<String, dynamic> json)
      : efficiency = json['efficiency'] ?? 0,
        skill = json['skill'] ?? 0,
        luck = json['luck'] ?? 0,
        durable = json['durable'] ?? 0;

  Map<String, dynamic> toJson() => {
    'efficiency': efficiency,
    'skill': skill,
    'luck': luck,
    'durable': durable,
  };

}

enum VFERarity {
  Common,
  Elite,
  Rare,
  Epic,
}
