import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/horizontal_steps.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class NewWalletStepThree extends StatefulWidget {
  NewWalletStepThree(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/create/stepthree';

  @override
  State<NewWalletStepThree> createState() => _NewWalletStepThreeState();
}

class _NewWalletStepThreeState extends State<NewWalletStepThree> {
  final _backgroundColor = HexColor('#956DFD');
  final _buttonHeight = 50.h;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();
  final TextEditingController _pass2Ctrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
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
                          Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(children: [
                                    stepsView(),
                                    inputsView(),
                                  ]))),
                          Expanded(flex: 0, child: buttonView()),
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
      title: const Text('Set Password',
          style: TextStyle(color: Colors.white)),
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
        currentIndex: 2,
        textStyle: TextStyle(fontSize: 14, color: Colors.black));
  }

  Widget inputsView() {
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
                  child: const Text('Account Name',
                      style: TextStyle(color: Colors.black, fontSize: 18))),
              TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Your nickname is also the wallet name",
                    focusedBorder: focusedBorder(),
                    enabledBorder: inputBorder(),
                    filled: true,
                    fillColor: HexColor('fbf7f7'),
                  ),
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.black),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ]),
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 16.h, bottom: 16.h),
                  width: double.infinity,
                  child: const Text('Wallet Password',
                      style: TextStyle(color: Colors.black, fontSize: 18))),
              TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Set wallet unlock password",
                    focusedBorder: focusedBorder(),
                    enabledBorder: inputBorder(),
                    filled: true,
                    fillColor: HexColor('fbf7f7'),
                  ),
                  controller: _passCtrl,
                  style: const TextStyle(color: Colors.black),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  //verify password
                  validator: (v) {
                    return v!.trim().length > 6
                        ? null
                        : "Password less than 6 characters";
                  }),
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 16.h, bottom: 16.h),
                  width: double.infinity,
                  child: const Text('Confirm Password',
                      style: TextStyle(color: Colors.black, fontSize: 18))),
              TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter wallet password again",
                    focusedBorder: focusedBorder(),
                    enabledBorder: inputBorder(),
                    filled: true,
                    fillColor: HexColor('fbf7f7'),
                  ),
                  controller: _pass2Ctrl,
                  style: const TextStyle(color: Colors.black),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  //verify password
                  validator: (v) {
                    return v!.trim().length > 6
                        ? null
                        : "Password less than 6 characters";
                  }),
            ])));
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

  Widget buttonView() {
    return Container(
        margin: EdgeInsets.only(bottom: 28.h),
        height: _buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
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
}
