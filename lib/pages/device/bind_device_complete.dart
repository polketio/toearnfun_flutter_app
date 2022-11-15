import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class BindDeviceComplete extends StatefulWidget {
  BindDeviceComplete(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/device/bind_device_complete';

  @override
  State<BindDeviceComplete> createState() => _BindDeviceCompleteState();
}

class _BindDeviceCompleteState extends State<BindDeviceComplete> {
  final _backgroundColor = HexColor('#956DFD');
  final _roundColor = HexColor('#f9f7f7');

  int connectedStatus = 0; //0: page loading, 1: connected, 2: disconnected
  BluetoothDevice? deviceToBind;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      connectDeviceToBind();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget contentView;
    if (connectedStatus == 0) {
      contentView = BrnPageLoading(content: 'Connecting...');
    } else {
      contentView = bindDeviceView();
    }

    return Scaffold(
        backgroundColor: _roundColor,
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                child: contentView)));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(),
      centerTitle: true,
      title: Text('Bind Device', style: TextStyle(color: Colors.white)),
    );
  }

  Widget bindDeviceView() {
    return Container(
        padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
        alignment: Alignment.center,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: deviceView()),
              Expanded(flex: 0, child: buttonView(context)),
            ]));
  }

  Widget deviceView() {
    return Container(
      child: Column(
        children: [
          Text('Device'),
          Text('+'),
          Text('VFE'),
        ],
      ),
    );
  }

  Widget buttonView(BuildContext context) {
    return Container(
        height: 50.h,
        width: double.infinity,
        margin: EdgeInsets.only(top: 44.h),
        child: ElevatedButton(
          onPressed: () async {
            await bindDeviceOnchain(context);

          },
          child: const Text('Complete', style: TextStyle(fontSize: 24)),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
        ));
  }

  Future<void> connectDeviceToBind() async {
    int status = connectedStatus;
    final data = ModalRoute.of(context)?.settings.arguments as Map;
    BluetoothDevice device = data["device"];
    LogUtil.d("device: ${device.name}(${device.mac})");
    final connected = await BluetoothDeviceConnector.connect(device);
    if (connected) {
      deviceToBind = device;
      status = 1;
    } else {
      status = 0;
    }

    setState(() {
      connectedStatus = status;
    });
  }

  Future<void> bindDeviceOnchain(BuildContext context) async {
    if (deviceToBind != null) {
      final pubKey = await BluetoothDeviceConnector.writeSkipGetPublicKey();
      deviceToBind!.pubKey = pubKey;
      // add connected device
      await widget.plugin.store?.devices.addConnectedDevice(deviceToBind!);
      //auto reconnect device
      BluetoothDeviceConnector.autoScanAndConnect(pubKey);

      popToRootView();

    }
  }

  void popToRootView() {
    Navigator.of(context)
      ..pop()
      ..pop()
      ..pop();
  }
}
