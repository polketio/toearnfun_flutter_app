class User {
  String owner = "";
  int energyTotal = 0;
  int energy = 0;
  int createBlock = 0;
  int lastRestoreBlock = 0;
  int lastEarnedResetBlock = 0;
  String earningCap = "0";
  String earned = "0";

  User(this.owner);

  User.fromJson(Map<String, dynamic> json)
      : owner = json['owner'] ?? "",
        energyTotal = json['energyTotal'] ?? 0,
        energy = json['energy'] ?? 0,
        createBlock = json['createBlock'] ?? 0,
        lastRestoreBlock = json['lastRestoreBlock'] ?? 0,
        lastEarnedResetBlock = json['lastEarnedResetBlock'] ?? 0,
        earningCap = json['earningCap'] ?? "0",
        earned = json['earned'] ?? "0";

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'energyTotal': energyTotal,
        'energy': energy,
        'createBlock': createBlock,
        'lastRestoreBlock': lastRestoreBlock,
        'lastEarnedResetBlock': lastEarnedResetBlock,
        'earningCap': earningCap,
        'earned': earned,
      };
}
