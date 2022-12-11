import 'dart:async';
import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart';
import 'package:toearnfun_flutter_app/store/devices.dart';
import 'package:toearnfun_flutter_app/store/plugin_store.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
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

abstract class BluetoothDeviceObserver {
  void onScanning(BluetoothDevice bleDevice);

  void onScanFinished();

  void onReceiveDisplayData(SkipDisplayData display);

  void onReceiveSkipRealTimeResultData(SkipResultData result);

  void onReceiveSkipHistoryResultData(SkipResultData result);

  void onConnectSuccess(BluetoothDevice bleDevice);

  void onDisConnected(BluetoothDevice bleDevice);
}

class BluetoothDeviceConnector {
  static Type classType = BluetoothDeviceConnector;

  static bool _initialized = false;
  static List<BluetoothDeviceObserver> observers = [];
  static BluetoothDevice? connectedDevice;
  static Timer? _timer;
  static PluginStore? _store;
  static bool autoConnect = false;
  static String targetDeviceKey = '';

  //注意，这里的名称需要和Android原生中定义的一样
  static const MethodChannel _channel = MethodChannel('BluetoothFlutterPlugin');

  //The native Android actively calls the flutter-side event channel
  static const EventChannel _eventChannel =
      EventChannel('BluetoothFlutterPluginEvent');

  static void init(PluginStore store) {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _store = store;
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  static bool autoScanAndConnect(String deviceKey) {
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
      } else {
        LogUtil.d('device is connected');
      }
    });

    return true;
  }

  static void addObserver(BluetoothDeviceObserver o) {
    observers.add(o);
  }

  static void removeObserver(BluetoothDeviceObserver o) {
    observers.remove(o);
  }

  static Future<bool> checkBluetoothIsOpen() async {
    return await _channel.invokeMethod('checkBluetoothIsOpen');
  }

  static Future<void> scanDevice() async {
    return await _channel.invokeMethod('scanDevice');
  }

  static Future<bool> connect(BluetoothDevice device) async {
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
    }
    return connect;
  }

  static Future<bool> stopConnect() async {
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

  static Future<bool> registerCustomDataRxCallback() async {
    return await _channel.invokeMethod('registerCustomDataRxCallback');
  }

  static Future<bool> unregisterCustomDataRxCallback() async {
    return await _channel.invokeMethod('unregisterCustomDataRxCallback');
  }

  //检查蓝牙是否连接
  static Future<bool> checkStateOn() async {
    var param = false;
    return await _channel.invokeMethod('checkStateOn', param);
  }

  //设置跳绳模式
  static Future<String> setSkipMode() async {
    return await _channel.invokeMethod('setSkipMode');
  }

  //设备恢复出厂
  static Future<String> devRevert() async {
    return await _channel.invokeMethod('devRevert');
  }

  //获取设备公钥
  static Future<String> getPublicKey() async {
    return await _channel.invokeMethod('writeSkipGetPublicKey');
  }

  //设备复位
  static Future<String> devReset() async {
    return await _channel.invokeMethod('devReset');
  }

//同步设备时间
  static Future<String> syncDeviceTime() async {
    return await _channel.invokeMethod('syncDeviceTime');
  }

  //停止跳绳
  static Future<String> stopSkip() async {
    return await _channel.invokeMethod('stopSkip');
  }

  //创建设备ECC公钥
  static Future<String> generateNewKeypair() async {
    return await _channel.invokeMethod('writeSkipGenerateECCKey');
  }

  //绑定设备
  static Future<String> sigBindDevice(String accountId, int deviceNonce) async {
    final hash = Hash.ripemd160(accountId);
    final signature = await _channel.invokeMethod(
        'writeSkipBondDev', {'nonce': deviceNonce, 'address': hash});
    return signature;
  }

  // 自动连接已连接过的设备
  static void _autoConnect(BluetoothDevice device) {
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
  static void _onEvent(dynamic object) {
    LogUtil.d('onEvent: ${object.toString()}', tag: classType.toString());

    Map<String, dynamic> data = jsonDecode(object);
    String msgType = data['messageType'];
    dynamic content = data['messageContext'];
    switch (msgType) {
      case BlueEventMessageType.scanning:
        final device = BluetoothDevice.fromJson(content);
        for (var o in observers) {
          o.onScanning(device);
        }
        //Attempt to automatically connect connected devices
        _autoConnect(device);
        break;
      case BlueEventMessageType.onDisConnected:
        final device = BluetoothDevice.fromJson(content);
        for (var o in observers) {
          o.onDisConnected(device);
        }
        connectedDevice = null;
        _store!.devices.disconnectDevice();
        break;
      case BlueEventMessageType.skipDisplayData:
        final res = SkipDisplayData.fromJson(content);
        for (var o in observers) {
          o.onReceiveDisplayData(res);
        }
        break;
      case BlueEventMessageType.skipResultData:
        final res = SkipResultData.fromJson(content);
        res.deviceKey = targetDeviceKey;
        for (var o in observers) {
          o.onReceiveSkipRealTimeResultData(res);
        }
        _store!.report.addTrainingReport(res);
        break;
      case BlueEventMessageType.skipHistoryData:
        final res = SkipResultData.fromJson(content);
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
