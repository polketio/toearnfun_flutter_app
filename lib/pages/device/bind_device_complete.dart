import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/consts.dart';
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
  int itemIdOfVFE = 0;

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
      leading: MyBackButton(onBack: () async {
        BrnLoadingDialog.show(context,
            content: 'Disconnecting', barrierDismissible: false);
        await BluetoothDeviceConnector.stopConnect();
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        BrnLoadingDialog.dismiss(context);
        Navigator.of(context).pop();
      }),
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
    String vfeImage = '';
    if (itemIdOfVFE != 0) {
      vfeImage = 'assets/images/vfe-card.png';
    } else {
      vfeImage = 'assets/images/blindbox.png';
    }
    return Container(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 32.h)),
          Image.asset('assets/images/device-bind-success.png'),
          Padding(padding: EdgeInsets.only(top: 32.h)),
          Image.asset('assets/images/icon-bond.png'),
          Padding(padding: EdgeInsets.only(top: 32.h)),
          Image.asset(vfeImage),
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
            BrnLoadingDialog.show(context,
                content: 'Binding', barrierDismissible: false);
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
            BrnLoadingDialog.show(context,
                content: 'Registering', barrierDismissible: false);
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
    BluetoothDevice device = data['device'];
    itemIdOfVFE = data['itemIdOfVFE'] ?? 0;
    LogUtil.d('device: ${device.name}(${device.mac})');
    // LogUtil.d('itemIdOfVFE: $itemIdOfVFE');
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
    final accountId = widget.keyring.current.pubKey;
    final address = widget.keyring.current.address ?? '';

    if (accountId == null) {
      if (!mounted) return;
      BrnToast.show('Please create a wallet first', context);
      BrnLoadingDialog.dismiss(context);
      return;
    }

    if (deviceToBind != null) {
      final pubKey = await BluetoothDeviceConnector.getPublicKey();
      deviceToBind!.pubKey = pubKey;

      //check if device bond
      final deviceExisted = await widget.plugin.api.vfe.getDevice(pubKey);
      if (deviceExisted != null) {
        if (deviceExisted.status == DeviceStatus.Voided.name) {
          if (!mounted) return;
          BrnToast.show('This device is voided', context);
          BrnLoadingDialog.dismiss(context);
          return;
        }

        // check if device brandId and itemId is same as the VFE
        if (deviceExisted.itemId != itemIdOfVFE || itemIdOfVFE == 0) {
          if (deviceExisted.itemId != 0) {
            // LogUtil.d('itemIdOfVFE: $itemIdOfVFE');
            if (!mounted) return;
            BrnToast.show('This device is bond', context);
            BrnLoadingDialog.dismiss(context);
            return;
          }

          //the device is not bond, try to bind device
          final nonce = deviceExisted.nonce + 1;
          final signature =
              await BluetoothDeviceConnector.sigBindDevice(accountId, nonce);
          // LogUtil.d('signature: $signature');
          if (!mounted) return;
          final password = await widget.plugin.api.account
              .getPassword(context, widget.keyring.current);
          final result = await widget.plugin.api.vfe.bindDevice(address, pubKey,
              signature, nonce, itemIdOfVFE > 0 ? itemIdOfVFE : null, password);
          if (!result.success) {
            if (!mounted) return;
            BrnToast.show(result.error, context);
            BrnLoadingDialog.dismiss(context);
            return;
          }

          //load vfe
          await widget.plugin.loadUserVFEs(accountId!);
        }

        // add connected device
        await widget.plugin.store.devices.addConnectedDevice(deviceToBind!);
        //auto reconnect device
        BluetoothDeviceConnector.autoScanAndConnect(pubKey);

        if (!mounted) return;
        BrnLoadingDialog.dismiss(context);
        BrnToast.show('Bind device successfully', context);
        popToRootView();
      } else {
        if (!mounted) return;
        BrnLoadingDialog.dismiss(context);
        BrnToast.show('Device is not registered', context);
      }
    }
  }

  Future<void> registerDeviceOnChain(BuildContext context) async {
    final user = widget.keyring.current.address;
    var producerId = 0;
    if (user == null) {
      BrnToast.show('Please create a wallet first', context);
      BrnLoadingDialog.dismiss(context);
      return;
    }

    //check if user register producer
    final producers = await widget.plugin.api.vfe.getProducerAll();
    for (var p in producers) {
      if (p.owner == user) {
        producerId = p.id;
      }
    }
    if (producerId == 0) {
      if (!mounted) return;
      final password = await widget.plugin.api.account
          .getPassword(context, widget.keyring.current);
      final result = await widget.plugin.api.vfe.producerRegister(user, password);
      if (!mounted) return;
      if (!result.success) {
        BrnToast.show(result.error, context);
      } else {
        BrnToast.show('Register producer successfully', context);
      }
    } else {
      //generate new keypair for device
      final newPubKey = await BluetoothDeviceConnector.generateNewKeypair();
      if (!mounted) return;
      final password = await widget.plugin.api.account.getPassword(
        context,
        widget.keyring.current,
      );
      final result = await widget.plugin.api.vfe
          .registerDevice(newPubKey, producerId, VFE_BRAND_ID, password);
      if (!mounted) return;
      if (!result.success) {
        BrnToast.show(result.error, context);
      } else {
        BrnToast.show('Register device successfully', context);
      }
    }

    if (!mounted) return;
    BrnLoadingDialog.dismiss(context);
  }
}
