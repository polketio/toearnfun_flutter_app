import 'package:get_storage/get_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';

part 'devices.g.dart';

class DevicesStore extends _DevicesStore with _$DevicesStore {
  DevicesStore(GetStorage storage) : super(storage);
}

abstract class _DevicesStore with Store {
  _DevicesStore(this.storage);

  final GetStorage storage;
  final String connectedDevicesKey = 'connected_devices';

  List<BluetoothDevice> _connectedDevices = [];

  List<BluetoothDevice> get connectedDevices {
    if (_connectedDevices.isEmpty) {
      loadConnectedDevices();
    }
    return _connectedDevices;
  }

  @observable
  ObservableList<BluetoothDevice> scannedDevices =
      ObservableList<BluetoothDevice>();

  @observable
  BluetoothDevice? currentConnected;

  Future<void> addConnectedDevice(BluetoothDevice device) async {
    if (_connectedDevices.isEmpty) {
      loadConnectedDevices();
    }

    for (var d in _connectedDevices) {
      if (d.mac == device.mac) {
        return;
      }
    }

    _connectedDevices.add(device);
    await storage.write(connectedDevicesKey, _connectedDevices);
  }

  void loadConnectedDevices() async {
    List cache = storage.read(connectedDevicesKey) ?? [];
    _connectedDevices = cache.map((e) => BluetoothDevice.fromJson(e)).toList();
  }

  @action
  Future<void> clearScannedDevices() async {
    scannedDevices.clear();
  }

  @action
  Future<void> addScannedDevice(BluetoothDevice device) async {
    for (var d in scannedDevices) {
      if (d.mac == device.mac) {
        return;
      }
    }
    scannedDevices.add(device);
  }

  @action
  void updateCurrentConnected(BluetoothDevice device) {
    currentConnected = device;
  }

  @action
  void disconnectDevice() {
    currentConnected = null;
  }
}
