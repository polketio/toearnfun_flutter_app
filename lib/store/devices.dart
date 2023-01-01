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

  List<FitnessDevice> _connectedDevices = [];

  List<FitnessDevice> get connectedDevices {
    if (_connectedDevices.isEmpty) {
      loadConnectedDevices();
    }
    return _connectedDevices;
  }

  @observable
  ObservableList<FitnessDevice> scannedDevices =
      ObservableList<FitnessDevice>();

  @observable
  FitnessDevice? currentConnected;

  Future<void> addConnectedDevice(FitnessDevice device) async {
    if (_connectedDevices.isEmpty) {
      loadConnectedDevices();
    }

    for (var d in _connectedDevices) {
      if (d.pubKey == device.pubKey) {
        return;
      }
    }

    _connectedDevices.add(device);

    List<Map<String, dynamic>> rawData =
    _connectedDevices.map((e) => e.toJson()).toList();
    await storage.write(connectedDevicesKey, rawData);
  }

  void loadConnectedDevices() async {
    List cache = storage.read(connectedDevicesKey) ?? [];
    _connectedDevices = cache.map((e) => FitnessDevice.fromJson(e)).toList();
  }

  @action
  Future<void> clearScannedDevices() async {
    scannedDevices.clear();
  }

  @action
  Future<void> addScannedDevice(FitnessDevice device) async {
    for (var d in scannedDevices) {
      if (d.mac == device.mac) {
        return;
      }
    }
    scannedDevices.add(device);
  }

  @action
  void updateCurrentConnected(FitnessDevice device) {
    currentConnected = device;
  }

  @action
  void disconnectDevice() {
    currentConnected = null;
  }

  FitnessDevice? getConnectedDevice(String deviceKey) {
    if(connectedDevices.isEmpty) {
      loadConnectedDevices();
    }
    for (var d in connectedDevices) {
      if (d.pubKey == deviceKey) {
        return d;
      }
    }
    return null;
  }
}
