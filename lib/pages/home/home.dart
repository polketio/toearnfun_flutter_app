import 'package:bruno/bruno.dart';
import 'package:ele_progress/ele_progress.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/pages/device/device_connect.dart';
import 'package:toearnfun_flutter_app/pages/training/training_reports.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class HomeView extends StatefulWidget {
  HomeView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  @override
  State<HomeView> createState() => _HomeViewState();
}

// HomeView
class _HomeViewState extends State<HomeView> {
  bool _refreshing = false;
  // static final EventChannel _eventChannel =
  //     EventChannel("BluetoothFlutterPluginEvent"); //原生平台主动调用flutter端事件通道

  @override
  void initState() {
    super.initState();
    // _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onErroe);
  }

  /**
   * 监听原生传递回来的值（通过eventChannel）
   */
  // void _onEvent(dynamic object) {
  //   print(object.toString() + "-------------从原生主动传递过来的值");
  // }
  //
  // void _onErroe(Object object) {
  //   print(object.toString() + "-------------从原生主动传递过来的值");
  // }

  Future<void> _updateBalances() async {
    if (!widget.plugin.connected) {
      // TODO: service is disconnected
      return;
    }

    setState(() {
      _refreshing = true;
    });
    await widget.plugin.updateBalances(widget.keyring.current);
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
        VFECard(),
        MyTrainingView(),
      ],
    );
  }
}

// VFE Card show VFE Image
class VFECard extends StatefulWidget {
  const VFECard({Key? key}) : super(key: key);

  @override
  State<VFECard> createState() => _VFECardState();
}

class _VFECardState extends State<VFECard> {
  @override
  Widget build(BuildContext context) {
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
              padding: EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 0),
              child: Image.asset("assets/images/img-Bound.png")),
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
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('STATUS',
                              style: TextStyle(
                                  color: Colors.greenAccent, fontSize: 12)),
                          SizedBox(
                              height: 24.h,
                              child: GestureDetector(
                                  child: const Text('Connected',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(DeviceConnectView.route);
                                  })),
                        ],
                      )),
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
  }
}

class MyTrainingView extends StatefulWidget {
  const MyTrainingView({Key? key}) : super(key: key);

  @override
  State<MyTrainingView> createState() => _MyTrainingViewState();
}

class _MyTrainingViewState extends State<MyTrainingView>
    with TickerProviderStateMixin {
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
}
