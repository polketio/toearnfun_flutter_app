import 'package:bruno/bruno.dart';
import 'package:ele_progress/ele_progress.dart';
import 'package:flukit/flukit.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_selector.dart';
import 'package:toearnfun_flutter_app/pages/training/training_reports.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_detail.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/simulated_device.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/types/user.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';
import 'package:toearnfun_flutter_app/utils/time.dart';

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
    implements JumpRopeDeviceObserver {
  bool _refreshing = false;
  String connectedStatus = 'disconnect';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    return Container(
      child: Observer(builder: (_) {
        String deviceKey = '';
        String itemId = 'N/A';
        int battery = 0;
        String vfeImage = 'assets/images/img-Unbound.png';
        int itemIdOfVFE = 0;
        final userSelectedVFE = widget.plugin.store.vfe.current;
        if (userSelectedVFE.itemId != null) {
          vfeImage = 'assets/images/vfe-card.png';
          itemId = '#${userSelectedVFE.itemId.toString().padLeft(4, '0')}';
          battery = userSelectedVFE.remainingBattery;
          deviceKey = userSelectedVFE.deviceKey.replaceFirst('0x', '');
          itemIdOfVFE = userSelectedVFE.itemId ?? 0;
          LogUtil.d('user current vfe is updated');
        }

        return Stack(children: <Widget>[
          // background
          Container(
            margin: EdgeInsets.fromLTRB(8.w, 0.h, 8.w, 0.h),
            child: Image.asset(
              'assets/images/home_bg.png',
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
                      final accountId = widget.keyring.current.pubKey;
                      if (accountId == null) {
                        BrnToast.show('Please create a wallet first', context);
                        return;
                      }

                      if (itemIdOfVFE != 0) {
                        Navigator.of(context)
                            .pushNamed(VFEDetailView.route, arguments: {
                          'vfeDetail': userSelectedVFE,
                        });
                      } else {
                        BindDeviceSelector.showDeviceTypesSelector(
                            context, itemIdOfVFE);
                      }
                    },
                    child: Image.asset(vfeImage))),
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
                                child: Text(itemId,
                                    style: const TextStyle(
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
                              if (deviceKey.isEmpty) {
                                BrnToast.show(
                                    'Please bind the device first', context);
                                return;
                              }

                              final device = widget.plugin.store.devices
                                  .getConnectedDevice(deviceKey);
                              final simulated = device?.simulated ?? false;
                              JumpRopeDeviceConnector connector;
                              if (simulated) {
                                connector = SimulatedDeviceConnector();
                              } else {
                                connector = BluetoothDeviceConnector();
                              }
                              connector.addObserver(this);
                              final existed =
                                  connector.autoScanAndConnect(deviceKey);
                              if (existed) {
                                setState(() {
                                  connectedStatus = 'connecting...';
                                });
                              } else {
                                setState(() {
                                  connectedStatus = 'disconnected';
                                });
                                BrnToast.show('Device is not existed', context);
                                BindDeviceSelector.showDeviceTypesSelector(
                                    context, itemIdOfVFE);
                              }
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
                                    progress: battery,
                                    colors: [HexColor('#b7e9e0')],
                                    backgroundColor: Colors.grey,
                                    textStyle: const TextStyle(
                                        color: Colors.white, fontSize: 12))),
                          ],
                        ))
                  ],
                ))
          ]),
        ]);
      }),
    );
  }

  Widget myTrainingView(BuildContext context) {
    return Observer(builder: (_) {
      final userState = widget.plugin.store.vfe.userState;

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
                    child: dailyTrainingView(context, userState)),
                Expanded(
                    flex: 1,
                    child:
                        trainingCircularProgressIndicator(context, userState)),
              ],
            )
          ],
        ),
      ));
    });
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
  Widget dailyTrainingView(BuildContext context, User userState) {
    return Observer(builder: (_) {
      final userState = widget.plugin.store.vfe.userState;
      const decimals = 12;
      const symbol = 'FUN';
      final earningCap = userState.earningCap;
      final earned = userState.earned;
      final trainingTimeCap = 0.5 * userState.energyTotal;
      final trainingTime = 0.5 * (userState.energyTotal - userState.energy);

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
                              Text(Fmt.balance(earned, decimals),
                                  style: const TextStyle(fontSize: 32)),
                              Padding(
                                  padding: EdgeInsets.only(bottom: 6.w),
                                  child: Text(
                                      ' / ${Fmt.balance(earningCap, decimals)} $symbol',
                                      style: const TextStyle(
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
                              Text('$trainingTime',
                                  style: TextStyle(fontSize: 32)),
                              Padding(
                                  padding: EdgeInsets.only(bottom: 6.w),
                                  child: Text(' / $trainingTimeCap minute',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16))),
                            ]))
                  ]),
            ],
          ));
    });
  }

  // daily training chart
  Widget trainingCircularProgressIndicator(
      BuildContext context, User userState) {
    return Observer(builder: (_) {
      double earnRatio = 0;
      double trainingTimeRatio = 0;
      String remainingTime = '';

      final earningCap = double.parse(userState.earningCap);
      if (earningCap > 0) {
        earnRatio = double.parse(userState.earned) / earningCap;
      }
      if (userState.energyTotal > 0) {
        trainingTimeRatio =
            (userState.energyTotal - userState.energy) / userState.energyTotal;
      }

      final currentHeight = widget.plugin.store.system.currentBlockNumber;
      final lastEnergyRecovery = widget.plugin.store.vfe.lastEnergyRecovery;
      if (widget.plugin.connected) {
        final energyRecoveryDuration =
            widget.plugin.api.vfe.energyRecoveryDuration;
        final nextEnergyRecovery = lastEnergyRecovery + energyRecoveryDuration;
        final expectedBlockTime =
            widget.plugin.api.system.expectedBlockTime / 1000;
        final remainingSeconds =
            (nextEnergyRecovery - currentHeight) * expectedBlockTime.round();
        remainingTime = formatDurationText(remainingSeconds);
      }

      // LogUtil.d('lastEnergyRecovery: $lastEnergyRecovery');
      // LogUtil.d('nextEnergyRecovery: $nextEnergyRecovery');
      // LogUtil.d('remainingSeconds: $remainingSeconds');
      // LogUtil.d('remaining time: $remainingTime');

      return Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Stack(alignment: Alignment.center, children: [
            LayoutBuilder(builder: (context, constraints) {
              // LogUtil.d('Circular 1 maxWidth: ${constraints.maxWidth}');
              // LogUtil.d('constraints maxHeight: ${constraints.maxHeight}');
              return GradientCircularProgressIndicator(
                backgroundColor: HexColor('#f5f5f5'),
                colors: [HexColor('#6cd1fe'), HexColor('#6cd1fe')],
                radius: constraints.maxWidth * 0.38,
                stokeWidth: 11.0,
                strokeCapRound: true,
                value: earnRatio,
              );
            }),
            LayoutBuilder(builder: (context, constraints) {
              // LogUtil.d('Circular 2 maxWidth: ${constraints.maxWidth}');
              child:
              return GradientCircularProgressIndicator(
                backgroundColor: HexColor('#f5f5f5'),
                colors: [HexColor('#956dfd'), HexColor('#956dfd')],
                radius: constraints.maxWidth * 0.30,
                stokeWidth: 11.0,
                strokeCapRound: true,
                value: trainingTimeRatio,
              );
            }),
            Column(
              children: [
                Text('Refill in', style: TextStyle(fontSize: 14)),
                Text(remainingTime,
                    style: TextStyle(fontSize: 14, color: HexColor('#956dfd'))),
              ],
            )
          ]));
    });
  }

  @override
  void onConnectSuccess(FitnessDevice bleDevice) {
    setState(() {
      connectedStatus = 'connected';
    });
  }

  @override
  void onDisConnected(FitnessDevice bleDevice) {
    setState(() {
      connectedStatus = 'disconnect';
    });
  }

  @override
  void onReceiveDisplayData(TrainingDisplay display) {}

  @override
  void onReceiveSkipHistoryResultData(TrainingReport result) {}

  @override
  void onReceiveSkipRealTimeResultData(TrainingReport result) {
    // LogUtil.d('training data encode: ${result.encodeData()}');
    // LogUtil.d('training signature: ${result.signature}');
    // LogUtil.d(
    //     'device pubkey: ${BluetoothDeviceConnector.connectedDevice?.pubKey ?? ''}');
  }

  @override
  void onScanFinished() {
    // LogUtil.d('onScanFinished');
  }

  @override
  void onScanning(FitnessDevice bleDevice) {
    setState(() {
      connectedStatus = 'connecting...';
    });
  }
}
