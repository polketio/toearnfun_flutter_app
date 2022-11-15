import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/api/types/addressIconData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/consts.dart';
import 'package:toearnfun_flutter_app/common/horizontal_steps.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_two.dart';
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

  final _tipsColor = HexColor('#BFC0D0');
  final _backgroundColor = HexColor('#956DFD');

  AddressIconDataWithMnemonic _addressIcon = AddressIconDataWithMnemonic();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.only(top: 28.h),
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
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
                      Expanded(flex: 0, child: stepsView()),
                      Expanded(flex: 1, child: mnemonicView()),
                      Expanded(flex: 0, child: buttonView()),
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
      title: const Text('Write Down Passphrase', style: TextStyle(color: Colors.white)),
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

  Widget mnemonicView() {
    final mnemonics = _addressIcon.mnemonic ?? '';
    return Container(
        margin: EdgeInsets.only(top: 28.h),
        alignment: Alignment.centerLeft,
        child: Column(children: [
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 0.h, bottom: 16.h),
              width: double.infinity,
              child: const Text(
                  'Write down the phrase and store it in a safe place',
                  style: TextStyle(color: Colors.black, fontSize: 18))),
          Container(
              margin: EdgeInsets.only(top: 0.h, bottom: 16.h),
              width: double.infinity,
              child: Text(
                  'Do not use clipboard or screenshots on your mobile device, try to find secure methods for backup(e.g. paper)',
                  style: TextStyle(color: _tipsColor, fontSize: 12))),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 0.h, bottom: 16.h),
              width: double.infinity,
              child: const Text('Mnemonic passphrase',
                  style: TextStyle(color: Colors.black, fontSize: 18))),
          TextFormField(
            readOnly: true,
            maxLines: 4,
            minLines: 2,
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 0),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: HexColor('fbf7f7'), width: 0.0)),
              filled: true,
              fillColor: HexColor('fbf7f7'),
            ),
            style: TextStyle(color: _backgroundColor),
            controller: TextEditingController()
              ..text =
                  mnemonics,
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 16.h, bottom: 8.h),
              width: double.infinity,
              child: Text(
                  'Please make sure to write down your phrase correctly and legibly.',
                  style: TextStyle(color: _tipsColor, fontSize: 12))),
        ]));
  }

  Widget buttonView() {
    return Container(
        height: 50.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(NewWalletStepTwo.route);
          },
          child: const Text('Continue', style: TextStyle(fontSize: 24)),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
        ));
  }

  Future<void> _generateAccount({String key = ''}) async {
    final addressInfo = await widget.plugin.sdk.api.keyring
        .generateMnemonic(widget.plugin.basic.ss58 ?? DEFAULT_SS58, key: key);

    setState(() {
      //update ui
      _addressIcon = addressInfo;
      LogUtil.d('current: ${widget.keyring.current.address}');
    });

    if (key.isEmpty && addressInfo.mnemonic != null) {
      widget.plugin.store?.account.setNewAccountKey(addressInfo.mnemonic!);
    }
  }
}
