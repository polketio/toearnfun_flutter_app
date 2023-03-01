import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/format.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class ChangePasswordView extends StatefulWidget {
  ChangePasswordView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/account/change_password';

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _backgroundColor = HexColor('#956DFD');
  final _buttonHeight = 50.h;
  bool canConfirm = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _pass2Ctrl = TextEditingController();

  @override
  void dispose() {
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _backgroundColor,
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.only(top: 28.h),
                padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 28.h),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: inputsView()),
                      Expanded(flex: 0, child: buttonView(context)),
                    ]))));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(onBack: _exit),
      centerTitle: true,
      title:
          const Text('Change Password', style: TextStyle(color: Colors.white)),
    );
  }

  Widget inputsView() {
    return Form(
        key: _formKey,
        child: Container(
            alignment: Alignment.centerLeft,
            child: Column(children: [
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 16.h, bottom: 16.h),
                  width: double.infinity,
                  child: const Text('New Password',
                      style: TextStyle(color: Colors.black, fontSize: 18))),
              TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Set wallet unlock password',
                    hintStyle: TextStyle(color: HexColor('c7c7c7')),
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
                    hintStyle: TextStyle(color: HexColor('c7c7c7')),
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
        borderSide: BorderSide(color: HexColor('9b9b9b'), width: 0.0));
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
          onPressed: () {
            _onSubmit(context);
          },
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
          child: const Text('Save', style: TextStyle(fontSize: 24)),
        ));
  }

  Future<void> _onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final password = await widget.plugin.api.account.getPassword(
        context,
        widget.keyring.current,
        true,
      );
      if (password == null) {
        return;
      }

      if (!mounted) return;
      BrnLoadingDialog.show(context,
          content: 'Processing...', barrierDismissible: false);

      final passNew = _passCtrl.text.trim();
      final pubKey = widget.keyring.current.pubKey!;
      await widget.plugin.sdk.api.keyring
          .changePassword(widget.keyring, password, passNew);
      await widget.plugin.store.account
          .saveUserWalletPassword(pubKey, _passCtrl.text);

      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnDialogManager.showSingleButtonDialog(context,
          showIcon: true,
          title: "Change password Successfully",
          label: "OK", onTap: () {
        Navigator.of(context).pop();
        _exit();
      });
    }
  }

  _exit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    await Future<void>.delayed(const Duration(milliseconds: 200), () {
      Navigator.of(context).pop();
    });
  }
}
