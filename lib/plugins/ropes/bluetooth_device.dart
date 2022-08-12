import 'package:flutter/services.dart';

class bluetooth_device{
  //注意，这里的名称需要和Android原生中定义的一样
  static const MethodChannel _channel = MethodChannel("BluetoothFlutterPlugin");

  static Future<String> getText() async{
    //传字符串给Android
    var param = "hello";

    //传递一个方法名，即调用Android的原生方法
    //注意这里的第二个参数
    return await _channel.invokeMethod("getText",param);
  }
  static Future<String> checkBluetoothIsOpen() async{
    return await _channel.invokeMethod("checkBluetoothIsOpen");
  }

  static Future<String>  scanDevice() async{
    return await _channel.invokeMethod("scanDevice");
  }
  static Future<String>  connect() async{
    return await _channel.invokeMethod("connect");
  }
}