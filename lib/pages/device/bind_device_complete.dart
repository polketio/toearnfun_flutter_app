import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/utils/crypto.dart';
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
            child: Container(alignment: Alignment.center, child: contentView)));
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
              Expanded(flex: 0, child: buttonRegisterView(context)),
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
        margin: EdgeInsets.only(top: 16.h),
        child: ElevatedButton(
          onPressed: () async {
            BrnLoadingDialog.show(context, content: 'Binding', barrierDismissible: false);
            await bindDeviceOnChain(context);

          },
          child: const Text('Bind', style: TextStyle(fontSize: 24)),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
        ));
  }

  Widget buttonRegisterView(BuildContext context) {
    return Container(
        height: 50.h,
        width: double.infinity,
        margin: EdgeInsets.only(top: 16.h),
        child: ElevatedButton(
          onPressed: () async {
            await registerDeviceOnChain(context);
          },
          child: const Text('Register', style: TextStyle(fontSize: 24)),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
        ));
  }

  void popToRootView() {
    Navigator.of(context)
      ..pop()
      ..pop()
      ..pop();
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

  Future<void> bindDeviceOnChain(BuildContext context) async {
    if (deviceToBind != null) {
      final pubKey = await BluetoothDeviceConnector.getPublicKey();
      deviceToBind!.pubKey = pubKey;

      //check if device bond
      final deviceExisted = await widget.plugin.api.vfe.queryDevice(pubKey);
      if (deviceExisted != null) {

        if (deviceExisted.status == DeviceStatus.Registered.name) {
          //the device is not bond, try to bind device
          final nonce = deviceExisted.nonce + 1;
          final accountId = widget.keyring.current.pubKey ?? "";
          final signature =
              await BluetoothDeviceConnector.sigBindDevice(accountId, nonce);
          // LogUtil.d("signature: $signature");
          await widget.plugin.api.vfe
              .bindDevice(pubKey, signature, nonce, null, "1234qwer");
        } else {
          //todo: check if device bond with this VFE

        }

        // add connected device
        await widget.plugin.store?.devices.addConnectedDevice(deviceToBind!);
        //auto reconnect device
        BluetoothDeviceConnector.autoScanAndConnect(pubKey);

        if (!mounted) return;
        BrnLoadingDialog.dismiss(context);
        BrnToast.show("Bind device successfully", context);
        popToRootView();
      } else {
        if (!mounted) return;
        BrnLoadingDialog.dismiss(context);
        BrnToast.show("Device is not registered", context);
      }
    }
  }

  Future<void> registerDeviceOnChain(BuildContext context) async {
    //generate new keypair for device
    final newPubKey = await BluetoothDeviceConnector.generateNewKeypair();
    final txid =
        await widget.plugin.api.vfe.registerDevice(newPubKey, 2, 1, "1234qwer");
  }
}
