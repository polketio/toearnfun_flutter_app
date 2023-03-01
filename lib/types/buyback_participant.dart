class BuybackParticipant {
  String locked = '0';
  String rewards = '0';
  bool withdrew = false;

  BuybackParticipant.fromJson(Map<String, dynamic> json)
      : locked = json['locked'].toString() ?? '0',
        rewards = json['rewards'].toString() ?? '0',
        withdrew = json['withdrew'] ?? false;

  Map<String, dynamic> toJson() => {
        'locked': locked,
        'rewards': rewards,
        'withdrew': withdrew,
      };
}
