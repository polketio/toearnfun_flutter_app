import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class VFEChargeView extends StatefulWidget {
  VFEChargeView(this.plugin, this.keyring, this.vfeDetail, this.doConfirm);

  final PluginPolket plugin;
  final Keyring keyring;
  final VFEDetail vfeDetail;
  final Function(int chargeNum) doConfirm;

  @override
  State<VFEChargeView> createState() => _VFEChargeViewState();

  static showDialogView(PluginPolket plugin, Keyring keyring, VFEDetail vfe, {required Function(int chargeNum) doConfirm}) {
    final contentView = VFEChargeView(plugin, keyring, vfe, doConfirm);
    return YYDialog().build()
      ..margin = EdgeInsets.only(left: 24.w, right: 24.w)
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..widget(contentView)
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }
}

class _VFEChargeViewState extends State<VFEChargeView> {
  final _buttonTextColor = HexColor('#956DFD');
  int remainingBattery = 0;
  int restoreBattery = 0;
  int chargeAmount = 0;
  String chargeCost = '0';

  @override
  void initState() {
    super.initState();
    remainingBattery = widget.vfeDetail.remainingBattery;
    restoreBattery = widget.vfeDetail.remainingBattery;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        titleView(context),
        vfeView(context),
        chargeBarView(context),
        bottomView(context),
      ],
    ));
  }

  Widget titleView(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 21.h),
        alignment: Alignment.center,
        child: Text('CHARGE', style: TextStyle(fontSize: 22)));
  }

  Widget vfeView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.h),
      alignment: Alignment.center,
      child: Image.asset('assets/images/vfe-item-common.png'),
    );
  }

  Widget chargeBarView(BuildContext context) {
    final decimals = widget.plugin.store.vfe.incentiveToken?.decimals ?? 12;
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // current battery, slider bar, cost
          Text('Battery: $restoreBattery%', style: TextStyle(fontSize: 18)),
          Container(
              padding: EdgeInsets.only(left: 8.w, right: 8.w),
              height: 60.h,
              child: Slider(
                min: 0.0,
                max: 100.0,
                value: restoreBattery.toDouble(),
                onChanged: (v) {
                  final value = v.round();
                  if (value >= remainingBattery) {
                    setState(() {
                      restoreBattery = value;
                    });
                  }
                },
                onChangeEnd: (v) async {
                  final brandId = widget.vfeDetail.brandId ?? 0;
                  final itemId = widget.vfeDetail.itemId ?? 0;

                  chargeAmount = v.round() - remainingBattery;
                  chargeAmount = chargeAmount > 0 ? chargeAmount : 0;
                  LogUtil.d('chargeAmount = $chargeAmount');
                  String costs = await widget.plugin.api.vfe
                      .getChargingCosts(brandId, itemId, chargeAmount);
                  costs = Fmt.balance(costs, decimals);
                  // LogUtil.d('chargeCost = $chargeCost');
                  setState(() {
                    chargeCost = costs;
                  });
                },
              )),
          Container(
              padding: EdgeInsets.only(left: 24.w, right: 24.w),
              height: 44.h,
              child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.all(0),
                  color: HexColor('#f5f5f5'),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.w,
                        color: Colors.black, //<-- SEE HERE
                      ),
                      borderRadius: BorderRadius.circular(22.w)),
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Cost'), Text('$chargeCost FUN')])))),
        ],
      ),
    );
  }

  Widget bottomView(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        child: SizedBox(
            height: 80.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel',
                        style:
                            TextStyle(fontSize: 18, color: _buttonTextColor))),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.doConfirm(chargeAmount);
                    },
                    child: Text('Confirm',
                        style:
                            TextStyle(fontSize: 18, color: _buttonTextColor))),
              ],
            )));
  }
}
