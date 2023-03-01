import 'dart:async';
import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/simulated_device.dart';
import 'package:toearnfun_flutter_app/store/devices.dart';
import 'package:toearnfun_flutter_app/store/plugin_store.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/utils/crypto.dart';

// messageType = 0：扫描蓝牙设备，1: 实时跳绳数据，2：实时跳绳结果，3：历史跳绳结果
class BlueEventMessageType {
  static const String scanning = '0';
  static const String skipDisplayData = '1';
  static const String skipResultData = '2';
  static const String skipHistoryData = '3';
  static const String onScanFinished = '4';
  static const String onDisConnected = '5';
}

abstract class JumpRopeDeviceObserver {
  void onScanning(FitnessDevice bleDevice);

  void onScanFinished();

  void onReceiveDisplayData(TrainingDisplay display);

  void onReceiveSkipRealTimeResultData(TrainingReport result);

  void onReceiveSkipHistoryResultData(TrainingReport result);

  void onConnectSuccess(FitnessDevice bleDevice);

  void onDisConnected(FitnessDevice bleDevice);
}

abstract class JumpRopeDeviceConnector {

  static void init(PluginStore store) {
    SimulatedDeviceConnector().init(store);
    BluetoothDeviceConnector().init(store);
  }

  bool autoScanAndConnect(String deviceKey);

  void addObserver(JumpRopeDeviceObserver o);

  void removeObserver(JumpRopeDeviceObserver o);

  Future<void> scanDevice();

  Future<bool> connect(FitnessDevice device);

  Future<bool> stopConnect();

  Future<String> setSkipMode();

  Future<String> getPublicKey();

  Future<String> stopSkip();

  Future<String> generateNewKeypair();

  Future<String> sigBindDevice(String accountId, int deviceNonce);
}

class BluetoothDeviceConnector implements JumpRopeDeviceConnector {
  static Type classType = BluetoothDeviceConnector;

  BluetoothDeviceConnector._internal();

  factory BluetoothDeviceConnector() => _instance;

  static final BluetoothDeviceConnector _instance =
      BluetoothDeviceConnector._internal();

  bool _initialized = false;
  Set<JumpRopeDeviceObserver> observers = <JumpRopeDeviceObserver>{};
  FitnessDevice? connectedDevice;
  Timer? _timer;
  PluginStore? _store;
  bool autoConnect = false;
  String targetDeviceKey = '';

  //注意，这里的名称需要和Android原生中定义的一样
  final MethodChannel _channel = MethodChannel('BluetoothFlutterPlugin');

  //The native Android actively calls the flutter-side event channel
  final EventChannel _eventChannel =
      EventChannel('BluetoothFlutterPluginEvent');

  void init(PluginStore store) {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _store = store;
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  bool autoScanAndConnect(String deviceKey) {
    targetDeviceKey = deviceKey;
    LogUtil.d('targetDeviceKey = $targetDeviceKey');

    //check if targetDevice exist connectedDevices of store
    final existed = _store!.devices.connectedDevices
        .any((e) => e.pubKey == targetDeviceKey);
    if (!existed) {
      return false;
    }

    if (_timer != null) {
      return true;
    }

    // define a timer 5s
    _timer = Timer.periodic(Duration(seconds: 5), (t) {
      // load Connected devices
      final connectedDevices = _store!.devices.connectedDevices;
      if (connectedDevice == null && connectedDevices.isNotEmpty) {
        LogUtil.d('autoScanAndConnect');
        scanDevice();
      }
    });

    return true;
  }

  void addObserver(JumpRopeDeviceObserver o) {
    observers.add(o);
  }

  void removeObserver(JumpRopeDeviceObserver o) {
    observers.remove(o);
  }

  Future<bool> checkBluetoothIsOpen() async {
    return await _channel.invokeMethod('checkBluetoothIsOpen');
  }

  Future<void> scanDevice() async {
    return await _channel.invokeMethod('scanDevice');
  }

  Future<bool> connect(FitnessDevice device) async {
    final isConnected = await checkStateOn();
    if (isConnected) {
      return true;
    }
    final connect = await _channel.invokeMethod('connect', device.mac);
    if (connect) {
      await registerCustomDataRxCallback();
      connectedDevice = device;
      _store!.devices.updateCurrentConnected(device);

      for (var o in observers) {
        o.onConnectSuccess(device);
      }
      LogUtil.d('device is connected');
      syncDeviceTime(); //sync device time
    }
    return connect;
  }

  Future<bool> stopConnect() async {
    final isConnected = await checkStateOn();
    if (!isConnected) {
      return false;
    }

    _timer?.cancel();
    _timer = null;
    final connect = await _channel.invokeMethod('stopConnect');
    if (!connect) {
      targetDeviceKey = '';
      unregisterCustomDataRxCallback();
      _store!.devices.disconnectDevice();
    }
    return connect;
  }

  Future<bool> registerCustomDataRxCallback() async {
    return await _channel.invokeMethod('registerCustomDataRxCallback');
  }

  Future<bool> unregisterCustomDataRxCallback() async {
    return await _channel.invokeMethod('unregisterCustomDataRxCallback');
  }

  //检查蓝牙是否连接
  Future<bool> checkStateOn() async {
    var param = false;
    return await _channel.invokeMethod('checkStateOn', param);
  }

  //设置跳绳模式
  Future<String> setSkipMode() async {
    return await _channel.invokeMethod('setSkipMode');
  }

  //设备恢复出厂
  Future<String> devRevert() async {
    return await _channel.invokeMethod('devRevert');
  }

  //获取设备公钥
  Future<String> getPublicKey() async {
    return await _channel.invokeMethod('writeSkipGetPublicKey');
  }

  //设备复位
  Future<String> devReset() async {
    return await _channel.invokeMethod('devReset');
  }

  //同步设备时间
  Future<bool> syncDeviceTime() async {
    return await _channel.invokeMethod('syncDeviceTime');
  }

  //停止跳绳
  Future<String> stopSkip() async {
    return await _channel.invokeMethod('stopSkip');
  }

  //创建设备ECC公钥
  Future<String> generateNewKeypair() async {
    return await _channel.invokeMethod('writeSkipGenerateECCKey');
  }

  //绑定设备
  Future<String> sigBindDevice(String accountId, int deviceNonce) async {
    final hash = Hash.ripemd160(accountId);
    final signature = await _channel.invokeMethod(
        'writeSkipBondDev', {'nonce': deviceNonce, 'address': hash});
    return signature;
  }

  // 自动连接已连接过的设备
  void _autoConnect(FitnessDevice device) {
    if (_timer == null) {
      return;
    }
    final connectedDevices = _store!.devices.connectedDevices;
    if (connectedDevices != null && connectedDevices.isNotEmpty) {
      for (var d in connectedDevices) {
        if (d.mac == device.mac) {
          if (targetDeviceKey.isNotEmpty) {
            if (d.pubKey == targetDeviceKey) {
              device.pubKey = targetDeviceKey;
              connect(device);
            }
          } else {
            connect(device);
          }
        }
      }
    }
  }

  // Listen to the value passed back natively (via eventChannel)
  void _onEvent(dynamic object) {
    LogUtil.d('onEvent: ${object.toString()}', tag: classType.toString());

    Map<String, dynamic> data = jsonDecode(object);
    String msgType = data['messageType'];
    dynamic content = data['messageContext'];
    switch (msgType) {
      case BlueEventMessageType.scanning:
        final device = FitnessDevice.fromJson(content);
        for (var o in observers) {
          o.onScanning(device);
        }
        //Attempt to automatically connect connected devices
        _autoConnect(device);
        break;
      case BlueEventMessageType.onDisConnected:
        final device = FitnessDevice.fromJson(content);
        for (var o in observers) {
          o.onDisConnected(device);
        }
        connectedDevice = null;
        _store!.devices.disconnectDevice();
        break;
      case BlueEventMessageType.skipDisplayData:
        final res = TrainingDisplay.fromJson(content);
        for (var o in observers) {
          o.onReceiveDisplayData(res);
        }
        break;
      case BlueEventMessageType.skipResultData:
        final res = newTrainingReportFromJson(content);
        res.deviceKey = targetDeviceKey;
        for (var o in observers) {
          o.onReceiveSkipRealTimeResultData(res);
        }
        _store!.report.addTrainingReport(res);
        break;
      case BlueEventMessageType.skipHistoryData:
        final res = newTrainingReportFromJson(content);
        res.deviceKey = targetDeviceKey;
        for (var o in observers) {
          o.onReceiveSkipHistoryResultData(res);
        }
        _store!.report.addTrainingReport(res);
        break;
      case BlueEventMessageType.onScanFinished:
        for (var o in observers) {
          o.onScanFinished();
        }
        break;
    }
  }

  static void _onError(Object err) {
    LogUtil.e('BluetoothFlutterPlugin got error: $err',
        tag: classType.toString());
  }
}
