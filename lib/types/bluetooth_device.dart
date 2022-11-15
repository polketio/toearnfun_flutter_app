class BluetoothDevice {
  String name = "";
  String mac = "";
  String pubKey = "";

  BluetoothDevice(this.name, this.mac);

  BluetoothDevice.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        mac = json['mac'],
        pubKey = json['pubKey'] ?? "";

  Map<String, dynamic> toJson() => {
        'name': name,
        'mac': mac,
        'pubKey': pubKey,
      };
}


