import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class VFELevelUpView extends StatefulWidget {
  VFELevelUpView(this.plugin, this.keyring, this.vfeDetail, this.doConfirm);

  final PluginPolket plugin;
  final Keyring keyring;
  final VFEDetail vfeDetail;
  final Function() doConfirm;

  @override
  State<VFELevelUpView> createState() => _VFELevelUpViewState();

  static showDialogView(PluginPolket plugin, Keyring keyring, VFEDetail vfe, {required Function() doConfirm}) {
    final contentView = VFELevelUpView(plugin, keyring, vfe, doConfirm);
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

class _VFELevelUpViewState extends State<VFELevelUpView> {
  final _buttonTextColor = HexColor('#956DFD');
  int currentLevel = 0;
  String chargeCost = '0';

  @override
  void initState() {
    super.initState();
    currentLevel = widget.vfeDetail.level;
    calculateLevelUpCosts();
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
        child: Text('LEVEL UP', style: TextStyle(fontSize: 22)));
  }

  Widget vfeView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.h),
      alignment: Alignment.center,
      child: Image.asset('assets/images/vfe-item-common.png'),
    );
  }

  Widget chargeBarView(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // current battery, slider bar, cost
          Text('Lv $currentLevel', style: TextStyle(fontSize: 18)),
          Container(
              padding: EdgeInsets.fromLTRB(32.w, 16.h, 0, 8.h),
              alignment: Alignment.centerLeft,
              child: Text('Level up to Lv ${currentLevel + 1}',
                  style: TextStyle(fontSize: 14))),
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
                      widget.doConfirm();
                    },
                    child: Text('Confirm',
                        style:
                            TextStyle(fontSize: 18, color: _buttonTextColor))),
              ],
            )));
  }

  Future<void> calculateLevelUpCosts() async {
    final brandId = widget.vfeDetail.brandId ?? 0;
    final itemId = widget.vfeDetail.itemId ?? 0;
    final owner = widget.vfeDetail.owner ?? '';
    final decimals = widget.plugin.store.vfe.incentiveToken?.decimals ?? 12;

    String costs =
        await widget.plugin.api.vfe.getLevelUpCosts(owner, brandId, itemId);
    costs = Fmt.balance(costs, decimals);
    // LogUtil.d('chargeCost = $chargeCost');
    setState(() {
      chargeCost = costs;
    });
  }
}
