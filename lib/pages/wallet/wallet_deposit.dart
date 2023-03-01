import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class WalletDepositView extends StatelessWidget {
  WalletDepositView(this.keyring);

  final Keyring keyring;

  final _backgroundColor = HexColor('#956DFD');

  static showDialogView(Keyring keyring) {
    final contentView = WalletDepositView(keyring);
    return YYDialog().build()
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..widget(contentView)
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 44.h),
        width: double.infinity,
        height: 440.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            titleView(),
            qrCodeView(context, keyring.current),
            addressView(context, keyring.current),
            buttonView(context, keyring.current),
          ],
        ));
  }

  Widget titleView() {
    return Column(children: [
      const Text(
        'Receive',
        style: TextStyle(fontSize: 24),
      ),
      Padding(padding: EdgeInsets.only(top: 12.h)),
      Container(
          height: 30.h,
          width: 80.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            border: Border.all(color: _backgroundColor, width: 0.5),
          ),
          child: Text(
            'Polket',
            style: TextStyle(fontSize: 14, color: _backgroundColor),
          ))
    ]);
  }

  Widget qrCodeView(BuildContext context, KeyPairData current) {
    final qrWidth = MediaQuery.of(context).size.width / 2;
    final codeAddress = current.address ?? '';
    return QrImage(
        data: codeAddress,
        size: qrWidth,
        // padding: const EdgeInsets.all(2),
        backgroundColor: Colors.white);
  }

  Widget addressView(BuildContext context, KeyPairData current) {
    return Text(
      current.address ?? '',
      style: const TextStyle(fontSize: 12, color: Colors.black),
    );
  }

  Widget buttonView(BuildContext context, KeyPairData current) {
    final width = MediaQuery.of(context).size.width / 2;
    return SizedBox(
        height: 44.h,
        width: width,
        child: ElevatedButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: current?.address));
            BrnToast.show('Copied', context);
          },
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
          child: const Text('Copy address',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ));
  }
}
