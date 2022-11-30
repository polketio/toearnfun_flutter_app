class Producer {
  int id = 0;
  String owner = "";

  Producer.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        owner = json['owner'] ?? "";

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner': owner,
      };
}
