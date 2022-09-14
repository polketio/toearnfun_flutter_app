import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
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
                      mainButton('Scan Device', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String devices = await bluetooth_device.scanDevice();
                        LogUtil.d('devices: $devices');
                      }),
                      mainButton('Connect Device', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String connect = await bluetooth_device.connect();
                        LogUtil.d('connect: $connect');
                      }),
                      mainButton('Get PublicKey', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String result = await bluetooth_device
                            .writeSkipGetPublicKey();
                        LogUtil.d('PublicKey: $result');
                      }),
                      mainButton('Generate ECC Key', 20, Colors.black,
                          Size(double.infinity, 44.h), () async {
                        String key =
                            await bluetooth_device.writeSkipGenerateECCKey();
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
