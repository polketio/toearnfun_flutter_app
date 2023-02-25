import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

class OrderItem {
  OrderItem(this.collectionId, this.itemId);

  int collectionId;
  int itemId;

  OrderItem.fromJson(Map<String, dynamic> json)
      : collectionId = json['collectionId'] ?? 0,
        itemId = json['itemId'] ?? 0;

  Map<String, dynamic> toJson() => {
        'collectionId': collectionId,
        'itemId': itemId,
      };
}

class Order {
  int id = 0;
  int assetId = 0;
  String owner = '';
  String? price;
  int deadline = 0;
  List<OrderItem> items = [];
  List<VFEDetail> details = [];

  Order.fromJson(Map<String, dynamic> json)
      : assetId = json['assetId'] ?? 0,
        price = json['price'].toString() ?? '0',
        deadline = json['deadline'] ?? 0,
        id = json['id'] ?? 0,
        owner = json['owner'] ?? '',
        items = (json['items'] as List ?? [])
            .map((e) => OrderItem.fromJson(e))
            .toList(),
        details = (json['details'] as List ?? [])
            .map((e) => VFEDetail.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() => {
        'assetId': assetId,
        'price': price,
        'deadline': deadline,
        'id': id,
        'owner': owner,
        'items': items.map((e) => e.toJson()).toList(),
        'details': details.map((e) => e.toJson()).toList(),
      };
}
