import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/horizontal_steps.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/format.dart';
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
  bool isCreate = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _pass2Ctrl = TextEditingController();

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
      title: const Text('Set Password', style: TextStyle(color: Colors.white)),
    );
  }

  Widget stepsView() {
    final data = ModalRoute.of(context)?.settings.arguments as Map;
    isCreate = data['isCreate'] ?? true;

    List<StepView> steps = [];
    int currentIndex = 0;
    if (isCreate) {
      steps = [
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
      ];
      currentIndex = 2;
    } else {
      steps = [
        StepView(
            doingIcon: Image.asset('assets/images/icon_1_on.png'),
            normalIcon: Image.asset('assets/images/icon_1_off.png'),
            stepContentText: 'Import'),
        StepView(
            doingIcon: Image.asset('assets/images/icon_2_on.png'),
            normalIcon: Image.asset('assets/images/icon_2_off.png'),
            stepContentText: 'Encrypt'),
      ];
      currentIndex = 1;
    }

    return HorizontalStepsView(
        steps: steps,
        currentIndex: currentIndex,
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
                  hintText: 'Your nickname is also the wallet name',
                  focusedBorder: focusedBorder(),
                  enabledBorder: inputBorder(),
                  filled: true,
                  fillColor: HexColor('fbf7f7'),
                ),
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.black),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: (v) {
                  return (v?.trim().isNotEmpty ?? false)
                      ? null
                      : 'name is empty';
                },
              ),
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
                    hintText: 'Set wallet unlock password',
                    focusedBorder: focusedBorder(),
                    enabledBorder: inputBorder(),
                    filled: true,
                    fillColor: HexColor('fbf7f7'),
                  ),
                  controller: _passCtrl,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.black),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  //verify password
                  validator: (v) {
                    if (!AppFmt.checkPassword(v!.trim())) {
                      return '6 to 18 digits and contains numbers and letters';
                    }

                    return null;
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
                    hintText: 'Enter wallet password again',
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
                    return _passCtrl.text != v
                        ? 'Passwords do not match'
                        : null;
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

  Widget buttonView(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 28.h),
        height: _buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await _onSubmit(context);
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

  Future<void> _onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      BrnLoadingDialog.show(context,
          content: 'Creating', barrierDismissible: false);
      widget.plugin.store.account.setNewAccount(_nameCtrl.text, _passCtrl.text);
      final json = await _importAccount(context);
      if (json != null) {
        final pubKey = json['pubKey'] ?? '';
        await widget.plugin.store.account
            .saveUserWalletPassword(pubKey, _passCtrl.text);
        widget.plugin.store.account.resetNewAccount();
        widget.plugin.store.account.setAccountCreated();
        await widget.plugin.changeAccount(widget.keyring.current);
        if (!mounted) return;
        BrnLoadingDialog.dismiss(context);
        Navigator.popUntil(context, ModalRoute.withName('/toearnfun/root'));
      } else {
        if (!mounted) return;
        BrnLoadingDialog.dismiss(context);
      }
    }
  }

  Future<Map?> _importAccount(BuildContext context) async {
    try {
      final json = await widget.plugin.api.account.importAccount(
        isFromCreatePage: true,
      );
      await widget.plugin.api.account.addAccount(
        json: json,
        isFromCreatePage: true,
      );

      return json;
    } catch (err) {
      BrnToast.show(err.toString(), context);
      return null;
    }
  }
}
