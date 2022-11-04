import 'package:flutter/services.dart';

class bluetooth_device {
  //注意，这里的名称需要和Android原生中定义的一样
  static const MethodChannel _channel = MethodChannel("BluetoothFlutterPlugin");

  static Future<String> getText() async {
    //传字符串给Android
    var param = "hello";

    //传递一个方法名，即调用Android的原生方法
    //注意这里的第二个参数
    return await _channel.invokeMethod("getText", param);
  }

  static Future<String> checkBluetoothIsOpen() async {
    return await _channel.invokeMethod("checkBluetoothIsOpen");
  }

  static Future<String> scanDevice() async {
    var param = "hello";
    return await _channel.invokeMethod("scanDevice", param);
  }

  static Future<bool> connect(String mac) async {
    return await _channel.invokeMethod("connect", mac);
  }

  static Future<bool> stopConnect() async {
    return await _channel.invokeMethod("stopConnect");
  }

  static Future<String> registerCustomDataRxCallback() async {
    return await _channel.invokeMethod("registerCustomDataRxCallback");
  }

  static Future<String> unregisterCustomDataRxCallback() async {
    return await _channel.invokeMethod("unregisterCustomDataRxCallback");
  }

  //检查蓝牙是否连接
  static Future<bool> checkStateOn() async {
    var param = false;
    return await _channel.invokeMethod("checkStateOn", param);
  }

  //设置跳绳模式
  static Future<String> setSkipMode() async {
    return await _channel.invokeMethod("setSkipMode");
  }

  //设备恢复出厂
  static Future<String> devRevert() async {
    return await _channel.invokeMethod("devRevert");
  }

  //获取设备公钥
  static Future<String> writeSkipGetPublicKey() async {
    return await _channel.invokeMethod("writeSkipGetPublicKey");
  }

  //设备复位
  static Future<String> devReset() async {
    return await _channel.invokeMethod("devReset");
  }

//同步设备时间
  static Future<String> syncDeviceTime() async {
    return await _channel.invokeMethod("syncDeviceTime");
  }

//停止跳绳
  static Future<String> stopSkip() async {
    return await _channel.invokeMethod("stopSkip");
  }

  //创建设备ECC公钥
  static Future<String> writeSkipGenerateECCKey() async {
    return await _channel.invokeMethod("writeSkipGenerateECCKey");
  }

  //绑定设备
  static Future<String> writeSkipBondDev(String nonce, String address) async {
    return await _channel
        .invokeMethod("writeSkipBondDev", {'nonce': nonce, 'address': address});
  }
}
