// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DevicesStore on _DevicesStore, Store {
  late final _$scannedDevicesAtom =
      Atom(name: '_DevicesStore.scannedDevices', context: context);

  @override
  ObservableList<BluetoothDevice> get scannedDevices {
    _$scannedDevicesAtom.reportRead();
    return super.scannedDevices;
  }

  @override
  set scannedDevices(ObservableList<BluetoothDevice> value) {
    _$scannedDevicesAtom.reportWrite(value, super.scannedDevices, () {
      super.scannedDevices = value;
    });
  }

  late final _$currentConnectedAtom =
      Atom(name: '_DevicesStore.currentConnected', context: context);

  @override
  BluetoothDevice? get currentConnected {
    _$currentConnectedAtom.reportRead();
    return super.currentConnected;
  }

  @override
  set currentConnected(BluetoothDevice? value) {
    _$currentConnectedAtom.reportWrite(value, super.currentConnected, () {
      super.currentConnected = value;
    });
  }

  late final _$clearScannedDevicesAsyncAction =
      AsyncAction('_DevicesStore.clearScannedDevices', context: context);

  @override
  Future<void> clearScannedDevices() {
    return _$clearScannedDevicesAsyncAction
        .run(() => super.clearScannedDevices());
  }

  late final _$addScannedDeviceAsyncAction =
      AsyncAction('_DevicesStore.addScannedDevice', context: context);

  @override
  Future<void> addScannedDevice(BluetoothDevice device) {
    return _$addScannedDeviceAsyncAction
        .run(() => super.addScannedDevice(device));
  }

  late final _$_DevicesStoreActionController =
      ActionController(name: '_DevicesStore', context: context);

  @override
  void updateCurrentConnected(BluetoothDevice device) {
    final _$actionInfo = _$_DevicesStoreActionController.startAction(
        name: '_DevicesStore.updateCurrentConnected');
    try {
      return super.updateCurrentConnected(device);
    } finally {
      _$_DevicesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void disconnectDevice() {
    final _$actionInfo = _$_DevicesStoreActionController.startAction(
        name: '_DevicesStore.disconnectDevice');
    try {
      return super.disconnectDevice();
    } finally {
      _$_DevicesStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
scannedDevices: ${scannedDevices},
currentConnected: ${currentConnected}
    ''';
  }
}
