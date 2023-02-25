import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class ChangeNameView extends StatefulWidget {
  ChangeNameView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/account/change_name';

  @override
  State<ChangeNameView> createState() => _ChangeNameViewState();
}

class _ChangeNameViewState extends State<ChangeNameView> {
  final _backgroundColor = HexColor('#956DFD');
  final _buttonHeight = 50.h;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  bool canConfirm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
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
      leading: MyBackButton(onBack: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        await Future<void>.delayed(const Duration(milliseconds: 200), () {
          Navigator.of(context).pop();
        });
      }),
      centerTitle: true,
      title: const Text('Change Name', style: TextStyle(color: Colors.white)),
    );
  }

  Widget inputsView() {
    final name = widget.keyring.current.name ?? '';
    return Form(
        key: _formKey,
        child: Container(
            alignment: Alignment.centerLeft,
            child: Column(children: [
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 0.h, bottom: 16.h),
                  width: double.infinity,
                  child: Text('Current Name: $name',
                      style:
                          const TextStyle(color: Colors.black, fontSize: 18))),
              TextFormField(
                maxLines: 1,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Edit new name',
                  hintStyle: TextStyle(color: HexColor('c7c7c7')),
                  focusedBorder: focusedBorder(),
                  enabledBorder: inputBorder(),
                  filled: true,
                  fillColor: HexColor('fbf7f7'),
                ),
                controller: _nameCtrl,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.black),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                validator: (v) {
                  return (v?.trim().isNotEmpty ?? false)
                      ? null
                      : 'Name is empty';
                },
                onChanged: (value) {
                  setState(() {
                    canConfirm = value.isNotEmpty;
                  });
                },
              ),
            ])));
  }

  InputBorder inputBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: HexColor('9b9b9b'), width: 1.0));
  }

  InputBorder focusedBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _backgroundColor, width: 1.0));
  }

  Widget buttonView(BuildContext context) {
    Function()? onPressed;
    Color btnColor;
    if (canConfirm) {
      onPressed = () {
        confirmChangeName(context);
      };
      btnColor = _backgroundColor;
    } else {
      onPressed = null;
      btnColor = Colors.black26;
    }

    return Container(
        margin: EdgeInsets.only(bottom: 28.h),
        height: _buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            backgroundColor: MaterialStateProperty.all(btnColor),
            alignment: Alignment.center,
          ),
          child: const Text('Save',
              style: TextStyle(fontSize: 24, color: Colors.white)),
        ));
  }

  confirmChangeName(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final newName = _nameCtrl.text.trim();
      widget.plugin.sdk.api.keyring
          .changeName(widget.keyring, newName);
      Navigator.pop(context, newName);
    }
  }
}
