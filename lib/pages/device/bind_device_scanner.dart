import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_complete.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_selector.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/simulated_device.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class BindDeviceScanner extends StatefulWidget {
  BindDeviceScanner(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/device/bind_device_scanner';

  @override
  State<BindDeviceScanner> createState() => _BindDeviceScannerState();
}

class _BindDeviceScannerState extends State<BindDeviceScanner>
    implements JumpRopeDeviceObserver {
  final _backgroundColor = HexColor('#956DFD');
  final _roundColor = HexColor('#f9f7f7');

  bool showRescanButton = false;
  DeviceType? deviceType;
  late JumpRopeDeviceConnector connector;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      deviceType = data['deviceType'];
      final simulated = deviceType?.simulated ?? false;
      if (simulated) {
        connector = SimulatedDeviceConnector();
      } else {
        connector = BluetoothDeviceConnector();
      }
      connector.addObserver(this);
      await scanDevices();
    });
  }

  @override
  void dispose() {
    connector.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      List<Widget> children = <Widget>[];
      final devices = widget.plugin.store.devices.scannedDevices;
      if (devices != null && devices.isNotEmpty) {
        children.add(
            Expanded(flex: 1, child: scannedDeviceListView(context, devices)));
      } else {
        children.add(Expanded(flex: 1, child: tipsDescView()));
      }

      if (showRescanButton) {
        children.add(Expanded(flex: 0, child: buttonView(context)));
      }

      return Scaffold(
          backgroundColor: _roundColor,
          appBar: getAppBarView(),
          body: SafeArea(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 28.h),
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: children))));
    });
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(),
      centerTitle: true,
      title: Text('Scan Device', style: TextStyle(color: Colors.white)),
    );
  }

  Widget tipsDescView() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 60.h, bottom: 60.h),
              child: Image.asset('assets/images/SearchingFor-img.png')),
          Text(
            'Scanning...',
            style: TextStyle(fontSize: 28),
          ),
          Padding(padding: EdgeInsets.only(top: 28.h)),
          Text('Please keep your phone close to the device.',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  // show currencies info
  Widget scannedDeviceListView(
      BuildContext context, List<FitnessDevice> devices) {
    return CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverFixedExtentList(
            itemExtent: 80.h,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final d = devices[index];
                final name = '${d.name} (${d.mac})';
                return Column(
                  children: [
                    ListTile(
                        title: Text(name, style: TextStyle(fontSize: 16)),
                        onTap: () async {
                          await selectDevice(context, d);
                        },
                        trailing:
                            Image.asset('assets/images/icon-Connect.png')),
                    const Divider(
                      height: 0.0,
                      indent: 0.0,
                      color: Colors.black26,
                    )
                  ],
                );
              },
              childCount: devices.length,
            ),
          )
        ]);
  }

  Widget buttonView(BuildContext context) {
    return Container(
        height: 50.h,
        width: double.infinity,
        margin: EdgeInsets.only(top: 44.h),
        child: ElevatedButton(
          onPressed: () async {
            await scanDevices();
          },
          child: const Text('Rescan', style: TextStyle(fontSize: 24)),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
        ));
  }

  Future<void> scanDevices() async {
    final connected = await connector.stopConnect();
    if (!connected) {
      setState(() {
        showRescanButton = false;
      });

      await widget.plugin.store.devices.clearScannedDevices();
      await connector.scanDevice();
    }
  }

  Future<void> selectDevice(BuildContext context, FitnessDevice device) async {
    final data = ModalRoute.of(context)?.settings.arguments as Map;
    final itemIdOfVFE = data['itemIdOfVFE'];

    Navigator.of(context).pushNamed(BindDeviceComplete.route, arguments: {
      'device': device,
      'itemIdOfVFE': itemIdOfVFE,
      'deviceType': deviceType,
    });
  }

  @override
  void onScanning(FitnessDevice bleDevice) {
    setState(() {
      widget.plugin.store.devices.addScannedDevice(bleDevice);
    });
  }

  @override
  void onScanFinished() {
    setState(() {
      showRescanButton = true;
    });
  }

  @override
  void onReceiveDisplayData(TrainingDisplay display) {}

  @override
  void onReceiveSkipHistoryResultData(TrainingReport result) {}

  @override
  void onReceiveSkipRealTimeResultData(TrainingReport result) {}

  @override
  void onDisConnected(FitnessDevice bleDevice) {}

  @override
  void onConnectSuccess(FitnessDevice bleDevice) {}
}
