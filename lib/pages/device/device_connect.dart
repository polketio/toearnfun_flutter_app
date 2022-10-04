import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
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
  static final EventChannel _eventChannel =
      EventChannel("BluetoothFlutterPluginEvent"); //原生平台主动调用flutter端事件通道

  @override
  void initState() {
    super.initState();
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  /**
   * 监听原生传递回来的值（通过eventChannel）
   */
  void _onEvent(dynamic object) {
    print(object.toString() + "-------------从原生主动传递过来的值");
  }

  void _onError(Object object) {
    print(object.toString() + "-------------从原生主动传递过来的值");
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
                        String isOpen =
                            await bluetooth_device.checkBluetoothIsOpen();
                        LogUtil.d('bluetooth is open: ${isOpen.toString()}');
                      }),
                      mainButton('check connect', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        bool isconnect = await bluetooth_device.checkStateOn();
                        LogUtil.d('isconnect: ${isconnect.toString()}');
                      }),
                      mainButton('Scan Device', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String devices = await bluetooth_device.scanDevice();
                        LogUtil.d('devices: $devices');
                      }),
                      mainButton('Connect Device', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        // String mac="22:22:22:22:22:22";
                        String mac = "FF:FF:FF:FF:FF:FF";
                        String connect = await bluetooth_device.connect(mac);
                        LogUtil.d('connect: $connect');
                      }),
                      mainButton('stop Connect Device', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String connect = await bluetooth_device.stopConnect();
                        LogUtil.d('connect: $connect');
                      }),
                      mainButton('Register', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String register = await bluetooth_device
                            .registerCustomDataRxCallback();
                        LogUtil.d('Register: $register');
                      }),
                      mainButton('unregister', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String register = await bluetooth_device
                            .unregisterCustomDataRxCallback();
                        LogUtil.d('Register: $register');
                      }),
                      mainButton('Get PublicKey', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String result =
                            await bluetooth_device.writeSkipGetPublicKey();
                        LogUtil.d('PublicKey: $result');
                      }),
                      mainButton('Generate ECC Key', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String key =
                            await bluetooth_device.writeSkipGenerateECCKey();
                        LogUtil.d('key: $key');
                      }),
                      mainButton('BondDev', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String nonce = "100";
                        String address =
                            "13ca5e29cb83e23796f96fc6e195a70bc7f5e970";
                        String key = await bluetooth_device.writeSkipBondDev(
                            nonce, address);
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
