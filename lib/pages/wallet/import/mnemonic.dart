import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/horizontal_steps.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_three.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class MnemonicRestoreWallet extends StatefulWidget {
  MnemonicRestoreWallet(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/import/mnemonic';

  @override
  State<MnemonicRestoreWallet> createState() => _MnemonicRestoreWalletState();
}

class _MnemonicRestoreWalletState extends State<MnemonicRestoreWallet> {
  final _tipsColor = HexColor('#BFC0D0');
  final _backgroundColor = HexColor('#956DFD');
  final _buttonHeight = 50.h;

  final TextEditingController _keyCtrl = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //5C4vzxJwrWbds1wdV5YmMEyeifXhJbFVPQSfzbr371aTLsLp
  final mnemonic_demo =
      'loyal spin hunt token initial banana scrub where can color risk zoo';

  @override
  void initState() {
    super.initState();
    _keyCtrl.text = mnemonic_demo;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: _backgroundColor,
            appBar: getAppBarView(),
            body: SafeArea(
                child: Container(
                    margin: EdgeInsets.only(top: 28.h),
                    padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 0),
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
                          Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(children: [
                                    stepsView(),
                                    mnemonicView(),
                                  ]))),
                          Expanded(flex: 0, child: buttonView(context)),
                        ])))));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(),
      centerTitle: true,
      title:
          const Text('Import Mnemonic', style: TextStyle(color: Colors.white)),
    );
  }

  Widget stepsView() {
    return HorizontalStepsView(
        steps: [
          StepView(
              doingIcon: Image.asset('assets/images/icon_1_on.png'),
              normalIcon: Image.asset('assets/images/icon_1_off.png'),
              stepContentText: 'Import'),
          StepView(
              doingIcon: Image.asset('assets/images/icon_2_on.png'),
              normalIcon: Image.asset('assets/images/icon_2_off.png'),
              stepContentText: 'Encrypt'),
        ],
        currentIndex: 0,
        textStyle: TextStyle(fontSize: 14, color: Colors.black));
  }

  Widget mnemonicView() {
    return Form(
        key: _formKey,
        child: Container(
            margin: EdgeInsets.only(top: 28.h, bottom: 28.h),
            alignment: Alignment.centerLeft,
            child: Column(children: [
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 0.h, bottom: 16.h),
                  width: double.infinity,
                  child: const Text('Enter the words in the right order',
                      style: TextStyle(color: Colors.black, fontSize: 18))),
              Container(
                  margin: EdgeInsets.only(top: 0.h, bottom: 16.h),
                  width: double.infinity,
                  child: Text(
                      'Write words separately with one space, no commas or other signs.',
                      style: TextStyle(color: _tipsColor, fontSize: 12))),
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 0.h, bottom: 16.h),
                  width: double.infinity,
                  child: const Text('Mnemonic passphrase',
                      style: TextStyle(color: Colors.black, fontSize: 18))),
              TextFormField(
                maxLines: 4,
                minLines: 2,
                enabled: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 0),
                  focusedBorder: focusedBorder(),
                  enabledBorder: inputBorder(),
                  filled: true,
                  fillColor: HexColor('fbf7f7'),
                ),
                style: TextStyle(color: _backgroundColor),
                controller: _keyCtrl,
                keyboardType: TextInputType.text,
                // onChanged: _onKeyChange,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 16.h, bottom: 8.h),
                  width: double.infinity,
                  child: Text(
                      'Typically 12-word phrase(but may be 15, 18, 21 or 24).',
                      style: TextStyle(color: _tipsColor, fontSize: 12))),
            ])));
  }

  Widget buttonView(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 28.h),
        height: _buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final valid = await _validateMnemonic(context);
              if (!valid) return;
            }

            widget.plugin.store.account.setNewAccountKey(_keyCtrl.text.trim());

            Navigator.of(context)
                .pushNamed(NewWalletStepThree.route, arguments: {
              "isCreate": false,
            });
          },
          child: const Text('Continue', style: TextStyle(fontSize: 24)),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
        ));
  }

  InputBorder inputBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: HexColor('fbf7f7'), width: 0.0));
  }

  InputBorder focusedBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _backgroundColor, width: 1.0));
  }

  Future<bool> _validateMnemonic(BuildContext context) async {
    BrnEnhanceOperationDialog enhanceOperationDialog =
        BrnEnhanceOperationDialog(
      iconType: BrnDialogConstants.iconAlert,
      context: context,
      titleText: "Warning",
      descText: "Invalid mnemonic, please enter again.",
      mainButtonText: "Got it",
      onMainButtonClick: () {
        setState(() {
          _keyCtrl.text = "";
        });
      },
    );

    final input = _keyCtrl.text.trim();

    int len = input.split(' ').length;
    if (len < 12) {
      enhanceOperationDialog.show();
      return false;
    }

    final res = await widget.plugin.sdk.api.keyring.checkMnemonicValid(input);
    if (!res) {
      enhanceOperationDialog.show();
    }
    return res;
  }
}
