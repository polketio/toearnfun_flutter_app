import 'package:toearnfun_flutter_app/types/asset_metadata.dart';

class BluetoothDevice {
  //off-chain info
  String name = "";
  String mac = "";
  String pubKey = "";

  //on-chain info
  String? sportType;
  int? brandId;
  int? itemId;
  int? producerId;
  String? status;
  int nonce = 0;
  int timestamp = 0;
  MintCost? mintCost;

  BluetoothDevice(this.name, this.mac);

  BluetoothDevice.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? "",
        mac = json['mac'] ?? "",
        pubKey = json['pubKey'] ?? "",
        // fill on-chain info
        sportType = json['sportType'] ?? "",
        brandId = json['brandId'] ?? 0,
        itemId = json['itemId'] ?? 0,
        producerId = json['producerId'] ?? 0,
        status = json['status'] ?? "",
        nonce = json['nonce'] ?? 0,
        timestamp = json['timestamp'] ?? 0,
        mintCost = json['mintCost'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'mac': mac,
        'pubKey': pubKey,
        'sportType': sportType,
        'brandId': brandId,
        'itemId': itemId,
        'producerId': producerId,
        'status': status,
        'nonce': nonce,
        'timestamp': timestamp,
        'mintCost': mintCost,
      };
}

enum DeviceStatus { Registered, Activated, Voided }

enum SportType { JumpRope, Run, Bicycle }
