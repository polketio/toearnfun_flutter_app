import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/horizontal_steps.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_three.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class NewWalletStepTwo extends StatefulWidget {
  NewWalletStepTwo(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/create/steptwo';

  @override
  State<NewWalletStepTwo> createState() => _NewWalletStepTwoState();
}

class _NewWalletStepTwoState extends State<NewWalletStepTwo> {
  final _tipsColor = HexColor('#BFC0D0');
  final _backgroundColor = HexColor('#956DFD');

  List<String> _wordsSelected = [];
  List<String> _wordsLeft = [];

  @override
  void initState() {
    super.initState();
    final mnemonics = widget.plugin.store.account.newAccount.key ?? '';
    _wordsSelected = <String>[];
    _wordsLeft = mnemonics.split(' ');
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
      title: const Text('Double Check Passphrase',
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
        currentIndex: 1,
        textStyle: TextStyle(fontSize: 14, color: Colors.black));
  }

  Widget mnemonicView() {
    return Container(
        margin: EdgeInsets.only(top: 12.h),
        alignment: Alignment.centerLeft,
        child: Column(children: [
          Container(
              width: double.infinity,
              height: 44.h,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Select the words in the right order.',
                        style: TextStyle(color: _tipsColor, fontSize: 12)),
                    IconButton(
                        alignment: Alignment.center,
                        onPressed: () {
                          setState(() {
                            if (_wordsSelected.isNotEmpty) {
                              // LogUtil.d('redo');
                              final lastWord = _wordsSelected.last;
                              _wordsLeft.add(lastWord);
                              _wordsSelected.remove(lastWord);
                            }
                          });
                        },
                        icon: Icon(Icons.redo, color: _backgroundColor)),
                  ])),
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
              controller: TextEditingController()
                ..text = _wordsSelected.join(' ') ?? '',
              style: TextStyle(color: _backgroundColor)),
          _buildWordsButtons(),
        ]));
  }

  Widget _buildWordsButtons() {
    if (_wordsLeft.length > 0) {
      _wordsLeft.sort();
    }
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _wordsLeft.map((e) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _wordsLeft.remove(e);
                _wordsSelected.add(e);
              });
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: _backgroundColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(e, style: TextStyle(color: _backgroundColor)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buttonView() {
    return Container(
        height: 50.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (_wordsSelected.join(' ') ==
                widget.plugin.store.account.newAccount.key) {
              Navigator.of(context).pushNamed(NewWalletStepThree.route);
            } else {
              BrnDialogManager.showSingleButtonDialog(context,
                  title: "Warning",
                  label: 'OK',
                  message: "Invalid mnemonic, please enter again.", onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _wordsLeft = widget
                          .plugin.store.account.newAccount.key
                          .split(' ');
                      _wordsSelected = [];
                    });
              });
            }
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
}
