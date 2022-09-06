import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/horizontal_steps.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class NewWalletStepOne extends StatefulWidget {
  NewWalletStepOne(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/create/stepone';

  @override
  State<NewWalletStepOne> createState() => _NewWalletStepOneState();
}

class _NewWalletStepOneState extends State<NewWalletStepOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor('#956DFD'),
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.only(top: 28.h),
                padding: EdgeInsets.fromLTRB(28.w, 44.h, 28.w, 44.h),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //[step-number, explain, tips, title, textfield, tips, button]
                      stepsView(),
                      const Text(
                          'Write down the phrase and store it in a safe place'),
                      const Text(
                          'Do not use clipboard or screenshots on your mobile device, try to find secure methods for backup(e.g. paper)'),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                            BorderRadius.circular(20)),
                        child: BrnTextBlockInputFormItem(
                          controller: TextEditingController()..text = "live predict mistake patch rural thumb direct memory peasant defense twelve catch",
                          prefixIconType: BrnPrefixIconType.normal,
                          isEdit: false,
                          maxLines: 4,
                        )
                      )

                    ]))));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      leading: MyBackButton(),
      centerTitle: true,
      title: const Text('New Wallet', style: TextStyle(color: Colors.white)),
    );
  }

  Widget stepsView() {
    return HorizontalStepsView(
        steps: [
          StepView(
              doingIcon: Image.asset('assets/images/icon_1_on.png'),
              normalIcon: Image.asset('assets/images/icon_1_off.png'),
              stepContentText: 'Backup'),
          StepView(
              doingIcon: Image.asset('assets/images/icon_2_on.png'),
              normalIcon: Image.asset('assets/images/icon_2_off.png'),
              stepContentText: 'Verify'),
          StepView(
              doingIcon: Image.asset('assets/images/icon_3_on.png'),
              normalIcon: Image.asset('assets/images/icon_3_off.png'),
              stepContentText: 'Encrypt'),
        ],
        currentIndex: 0,
        textStyle: TextStyle(fontSize: 14, color: Colors.black));
  }
}
