import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class DeviceConnectView extends StatefulWidget {
  DeviceConnectView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/device/connect';

  @override
  State<DeviceConnectView> createState() => _DeviceConnectViewState();
}

class _DeviceConnectViewState extends State<DeviceConnectView> {
  // static final EventChannel _eventChannel =
  //     EventChannel('BluetoothFlutterPluginEvent'); //原生平台主动调用flutter端事件通道

  @override
  void initState() {
    super.initState();
    // BluetoothDeviceConnector.init();
    // _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  /**
   * 监听原生传递回来的值（通过eventChannel）
   */
  void _onEvent(dynamic object) {
    /*
      messageType = 0：扫描蓝牙设备，1: 实时跳绳数据，2：实时跳绳结果，3：历史跳绳结果
      {
          'messageType': '2',
          'messageContext': {
              'SkipSecSum': '4',  //跳绳总时长
              'SkipCntSum': '18', //跳绳总次数
              'SkipValidSec': '4',
              'FreqAvg': '270', //平均频次
              'FreqMax': '270',   //最快频次
              'ConsecutiveSkipMaxNum': '18',  //最大连跳次数
              'SkipTripNum': '0', //绊绳次数
              'signature': ''
          }
      }

      {
          'messageType': '0',
          'messageContext': {
              'name': 'JC-2A',  //device name
              'mac': 'FF:FF:FF:FF:FF:FF', //device mac
              'Rssi': '-40'
          }
      }
     */

    print(object.toString() + '-------------从原生主动传递过来的值');
  }

  void _onError(Object object) {
    print(object.toString() + '-------------从原生主动传递过来的值');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor('#956DFD'),
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      mainButton('check bluetooth is open', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        bool isOpen = await BluetoothDeviceConnector
                            .checkBluetoothIsOpen();
                        LogUtil.d('bluetooth is open: ${isOpen.toString()}');
                      }),
                      mainButton('check connect', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        bool isconnect =
                            await BluetoothDeviceConnector.checkStateOn();
                        LogUtil.d('isconnect: ${isconnect.toString()}');
                      }),
                      mainButton('Scan Device', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        BluetoothDeviceConnector.scanDevice();
                      }),
                      mainButton('Connect Device', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        // String mac='22:22:22:22:22:22';
                        String mac = 'FF:FF:FF:FF:FF:FF';
                        bool connect =
                            await BluetoothDeviceConnector.connect(BluetoothDevice('demo', mac));
                        LogUtil.d('connect: $connect');
                      }),
                      mainButton('stop Connect Device', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        bool connect =
                            await BluetoothDeviceConnector.stopConnect();
                        LogUtil.d('connect: $connect');
                      }),
                      mainButton('Register', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        await BluetoothDeviceConnector
                            .registerCustomDataRxCallback();
                        LogUtil.d('registerCustomDataRxCallback');
                      }),
                      mainButton('unregister', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        await BluetoothDeviceConnector
                            .unregisterCustomDataRxCallback();
                        LogUtil.d('unregisterCustomDataRxCallback');
                      }),
                      mainButton('Get PublicKey', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String result = await BluetoothDeviceConnector
                            .getPublicKey();
                        LogUtil.d('PublicKey: $result');
                      }),
                      mainButton('Generate ECC Key', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String key = await BluetoothDeviceConnector
                            .generateNewKeypair();
                        LogUtil.d('key: $key');
                      }),
                      mainButton('BondDev', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        int nonce = 123;
                        String address =
                            '184f0bc2046b560ad6b6b6180726d023a2ff3987';
                        String key =
                            await BluetoothDeviceConnector.sigBindDevice(
                              address, nonce);
                        LogUtil.d('key: $key');
                      }),
                    ]))));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      leading: MyBackButton(),
    );
  }

  Widget mainButton(String title, double fontSize, Color textColor,
      Size buttonSize, VoidCallback? onPressed) {
    return Container(
        margin: EdgeInsets.only(bottom: 20.h),
        height: buttonSize.height,
        width: buttonSize.width,
        child: ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              backgroundColor: MaterialStateProperty.all(HexColor('#e9e0fe')),
              alignment: Alignment.centerLeft,
            ),
            onPressed: onPressed,
            child: Text(title,
                style: TextStyle(fontSize: fontSize, color: textColor))));
  }
}
