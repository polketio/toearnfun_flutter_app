import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_one.dart';
import 'package:toearnfun_flutter_app/pages/wallet/import/mnemonic.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class NewWalletWelcomeView extends StatefulWidget {
  NewWalletWelcomeView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/create/welcome';

  @override
  State<NewWalletWelcomeView> createState() => _CreateWalletWelcomeViewState();
}

class _CreateWalletWelcomeViewState extends State<NewWalletWelcomeView> {
  bool firstStart = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor('#956DFD'),
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //[logo, buttons]
                      Expanded(
                          flex: 1,
                          child: Image.asset('assets/images/icon_logo.png')),
                      Expanded(
                          flex: 1,
                          child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 30.h),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    mainButton(
                                        iconImageView(
                                            'assets/images/icon_create_wallet.png',
                                            44.w,
                                            HexColor('#874cf1'),
                                            EdgeInsets.only(right: 8.w)),
                                        'Create a new wallet',
                                        20,
                                        Colors.black,
                                        Size(double.infinity, 70.h),
                                        onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed(NewWalletStepOne.route);
                                    }),
                                    SizedBox(height: 22.h),
                                    mainButton(
                                        iconImageView(
                                            'assets/images/icon_import_wallet.png',
                                            44.w,
                                            HexColor('#874cf1'),
                                            EdgeInsets.only(right: 8.w)),
                                        'Import wallet',
                                        20,
                                        Colors.black,
                                        Size(double.infinity, 70.h),
                                        onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          MnemonicRestoreWallet.route);
                                    }),
                                  ])))
                    ]))));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      leading: firstStart ? null : MyBackButton(),
    );
  }

  Widget iconImageView(
      String img, double size, Color color, EdgeInsetsGeometry? padding) {
    return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            color: color,
          ),
          child: Image.asset(img),
        ));
  }

  Widget mainButton(Widget icon, String title, double fontSize, Color textColor,
      Size buttonSize,
      {VoidCallback? onPressed}) {
    return SizedBox(
        height: buttonSize.height,
        width: buttonSize.width,
        child: ElevatedButton.icon(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              backgroundColor: MaterialStateProperty.all(HexColor('#e9e0fe')),
              alignment: Alignment.centerLeft,
            ),
            onPressed: onPressed,
            icon: icon,
            label: Text(title,
                style: TextStyle(fontSize: fontSize, color: textColor))));
  }
}
