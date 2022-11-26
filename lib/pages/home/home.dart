import 'package:bruno/bruno.dart';
import 'package:ele_progress/ele_progress.dart';
import 'package:flukit/flukit.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_selector.dart';
import 'package:toearnfun_flutter_app/pages/device/device_connect.dart';
import 'package:toearnfun_flutter_app/pages/training/training_reports.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class HomeView extends StatefulWidget {
  HomeView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  @override
  State<HomeView> createState() => _HomeViewState();
}

// HomeView
class _HomeViewState extends State<HomeView>
    with TickerProviderStateMixin
    implements BluetoothDeviceObserver {
  bool _refreshing = false;
  String connectedStatus = "disconnect";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animationController.forward();
    BluetoothDeviceConnector.addObserver(this);

    Future.delayed(Duration(seconds: 5), () {
      _loadUserVFEs();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    BluetoothDeviceConnector.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadUserVFEs() async {
    if (!widget.plugin.connected) {
      // TODO: service is disconnected
      return;
    }

    setState(() {
      _refreshing = true;
    });
    final userAddr = widget.keyring.current?.address ?? "";
    final vfes =
        await widget.plugin.api.vfe.getVFEDetailsByAddress(userAddr, 1);
    vfes?.forEach((e) {
      LogUtil.d("vfe detail: $e}");
    });
    setState(() {
      _refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        vfeCardView(context),
        myTrainingView(context),
      ],
    );
  }

  Widget vfeCardView(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
        child: Stack(children: <Widget>[
          // background
          Container(
            margin: EdgeInsets.fromLTRB(8.w, 0.h, 8.w, 0.h),
            child: Image.asset(
              "assets/images/home_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          //col: [vfe-img, state-row]
          Column(children: [
            Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 0),
                child: GestureDetector(
                    onTap: () async {
                      //todo: check if user have any VFEs
                      LogUtil.d('showDeviceTypesSelector');
                      BindDeviceSelector.showDeviceTypesSelector(context);
                    },
                    child: Image.asset("assets/images/img-Bound.png"))),
            Padding(
                padding: EdgeInsets.only(top: 16.h, left: 24.w, right: 24.w),
                child: Row(
                  //row: [ID, status, power]
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text('VFE ID',
                                style: TextStyle(
                                    color: Colors.greenAccent, fontSize: 12)),
                            SizedBox(
                                height: 24.h,
                                child: const Text('#0001',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16))),
                          ],
                        )),
                    Expanded(
                        flex: 1,
                        child: GestureDetector(
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('STATUS',
                                    style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 12)),
                                SizedBox(
                                    height: 24.h,
                                    child: Text(connectedStatus,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16)))
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                connectedStatus = "connecting...";
                              });
                              const deviceKey =
                                  "0339d3e6e837d675ce77e85d708caf89ddcdbf53c8e510775c9cb9ec06282475a0";
                              BluetoothDeviceConnector.autoScanAndConnect(
                                  deviceKey);
                              // Navigator.of(context)
                              //     .pushNamed(DeviceConnectView.route);
                            })),
                    Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                                width: 80.w,
                                child: const Text('BATTERY',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 12))),
                            SizedBox(
                                width: 80.w,
                                height: 24.h,
                                child: EProgress(
                                    progress: 80,
                                    colors: [HexColor('#b7e9e0')],
                                    backgroundColor: Colors.grey,
                                    textStyle: const TextStyle(
                                        color: Colors.white, fontSize: 12))),
                          ],
                        ))
                  ],
                ))
          ]),
        ]),
      );
    });
  }

  Widget myTrainingView(BuildContext context) {
    return Flexible(
        child: Container(
      // height: 300,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      margin: EdgeInsets.fromLTRB(0.w, 8.h, 0.w, 0.h),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          //[title, arrow]
          trainingTitleView(context),
          //Row: [daily training, training chart]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  //col: [earn fun, training time]
                  child: dailyTrainingView(context)),
              Expanded(
                  flex: 1, child: trainingCircularProgressIndicator(context)),
            ],
          )
        ],
      ),
    ));
  }

  Widget trainingTitleView(BuildContext context) {
    return GestureDetector(
        child: Padding(
            //[title, arrow]
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'My Training',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(JumpRopeTrainingReportsView.route);
                  },
                  alignment: Alignment.centerRight,
                  icon: Image.asset('assets/images/icon-LeftArrow.png'),
                  // iconSize: 24.w,
                )
              ],
            )),
        onTap: () {
          Navigator.of(context).pushNamed(JumpRopeTrainingReportsView.route);
        });
  }

  // daily training data
  Widget dailyTrainingView(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      //disable click effect
                      overlayColor: MaterialStateProperty.all(
                          Colors.transparent), //disable click effect
                    ),
                    icon: Image.asset('assets/images/icon-Rope.png'),
                    label: Text('Earn FUN',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('0', style: TextStyle(fontSize: 32)),
                            Padding(
                                padding: EdgeInsets.only(bottom: 6.w),
                                child: Text(' / 200 FUN',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16))),
                          ]))
                ]),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      //disable click effect
                      overlayColor: MaterialStateProperty.all(
                          Colors.transparent), //disable click effect
                    ),
                    icon: Image.asset('assets/images/icon-Time.png'),
                    label: Text('Training Time',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('0', style: TextStyle(fontSize: 32)),
                            Padding(
                                padding: EdgeInsets.only(bottom: 6.w),
                                child: Text(' / 10 minute',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16))),
                          ]))
                ]),
          ],
        ));
  }

  // daily training chart
  Widget trainingCircularProgressIndicator(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Stack(alignment: Alignment.center, children: [
          LayoutBuilder(builder: (context, constraints) {
            // LogUtil.d('constraints: $constraints');
            return GradientCircularProgressIndicator(
              backgroundColor: HexColor('#f5f5f5'),
              colors: [HexColor('#6cd1fe'), HexColor('#6cd1fe')],
              radius: constraints.maxWidth * 0.38,
              stokeWidth: 11.0,
              strokeCapRound: true,
              value: CurvedAnimation(
                      parent: _animationController, curve: Curves.decelerate)
                  .value,
            );
          }),
          LayoutBuilder(builder: (context, constraints) {
            child:
            return GradientCircularProgressIndicator(
              backgroundColor: HexColor('#f5f5f5'),
              colors: [HexColor('#956dfd'), HexColor('#956dfd')],
              radius: constraints.maxWidth * 0.30,
              stokeWidth: 11.0,
              strokeCapRound: true,
              value: CurvedAnimation(
                      parent: _animationController, curve: Curves.decelerate)
                  .value,
            );
          }),
          IconButton(
              onPressed: null,
              icon: Image.asset('assets/images/icon-Exchange-fun.png'))
        ]));
  }

  @override
  void onConnectSuccess(BluetoothDevice bleDevice) {
    setState(() {
      connectedStatus = "connected";
    });
  }

  @override
  void onDisConnected(BluetoothDevice bleDevice) {
    setState(() {
      connectedStatus = "disconnect";
    });
  }

  @override
  void onReceiveDisplayData(SkipDisplayData display) {}

  @override
  void onReceiveSkipHistoryResultData(SkipResultData result) {}

  @override
  void onReceiveSkipRealTimeResultData(SkipResultData result) {
    LogUtil.d("training data encode: ${result.encodeData()}");
    LogUtil.d("training signature: ${result.signature}");
    LogUtil.d(
        "device pubkey: ${BluetoothDeviceConnector.connectedDevice?.pubKey ?? ""}");
  }

  @override
  void onScanFinished() {
    LogUtil.d("onScanFinished");
  }

  @override
  void onScanning(BluetoothDevice bleDevice) {
    setState(() {
      connectedStatus = "connecting...";
    });
  }
}
