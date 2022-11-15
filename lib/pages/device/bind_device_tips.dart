import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_scanner.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class BindDeviceTips extends StatefulWidget {
  BindDeviceTips(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/device/bind_device_tips';

  @override
  State<BindDeviceTips> createState() => _BindDeviceTipsState();
}

class _BindDeviceTipsState extends State<BindDeviceTips> {
  final _backgroundColor = HexColor('#956DFD');
  final _roundColor = HexColor('#f9f7f7');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _roundColor,
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
                alignment: Alignment.center,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: tipsDescView()),
                      Expanded(flex: 0, child: buttonView(context)),
                    ]))));
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

  Widget tipsDescView() {
    return Container(
      child: Column(
        children: [
          Text('How to bind?'),
          Text('Touch the power button to wake up the screen.'),
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
          onPressed: () {
            Navigator.of(context)
                .pushNamed(BindDeviceScanner.route);
          },
          child: const Text('Next', style: TextStyle(fontSize: 24)),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
        ));
  }
}
