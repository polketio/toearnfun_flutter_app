import 'package:flutter/services.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';

class DeviceConnector {
  //TODO: Save the locally connected devices.
  //TODO: Auto scan and connect device of VFE bond.
  //TODO: Manually retry the bluetooth connection

  //The native Android actively calls the flutter-side event channel
  static const EventChannel _eventChannel =
      EventChannel("BluetoothFlutterPluginEvent");

  BluetoothDevice? connectedDevice;

  void init() {
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  // Listen to the value passed back natively (via eventChannel)
  void _onEvent(dynamic object) {
    /*
      messageType = 0：扫描蓝牙设备，1: 实时跳绳数据，2：实时跳绳结果，3：历史跳绳结果
      {
          "messageType": "2",
          "messageContext": {
              "SkipSecSum": "4",  //跳绳总时长
              "SkipCntSum": "18", //跳绳总次数
              "SkipValidSec": "4",
              "FreqAvg": "270", //平均频次
              "FreqMax": "270",   //最快频次
              "ConsecutiveSkipMaxNum": "18",  //最大连跳次数
              "SkipTripNum": "0", //绊绳次数
              "signature": ""
          }
      }

      {
          "messageType": "0",
          "messageContext": {
              "name": "JC-2A",  //device name
              "mac": "FF:FF:FF:FF:FF:FF", //device mac
              "Rssi": "-40"
          }
      }
     */

    // print(object.toString() + "-------------从原生主动传递过来的值");
  }

  void _onError(Object object) {
    // print(object.toString() + "-------------从原生主动传递过来的值");
  }

  void scanDevice() {
    if (connectedDevice != null) {
      return;
    }
    BluetoothDeviceConnector.scanDevice();
  }

}
