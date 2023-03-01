import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class ExportAccountView extends StatefulWidget {
  ExportAccountView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/account/export_account';

  @override
  State<ExportAccountView> createState() => _ExportAccountViewState();
}

class _ExportAccountViewState extends State<ExportAccountView> {
  final _tipsColor = HexColor('#BFC0D0');
  final _backgroundColor = HexColor('#956DFD');

  final TextEditingController _keyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      SeedBackupData seedData = data['seed'];

      final hasDerivePath = seedData.type != 'keystore' &&
          (seedData.seed?.contains('/') ?? false);
      String seed = seedData.seed ?? '';
      // String path = '';
      if (hasDerivePath && seed.isNotEmpty) {
        final seedSplit = seed.split('/');
        seed = seedSplit[0];
        // path = '/${seedSplit.sublist(1).join('/')}';
      }

      setState(() {
        _keyCtrl.text = seed;
      });
    });
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
                    padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 28.h),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    child: mnemonicView()))));
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
          const Text('Backup Mnemonic', style: TextStyle(color: Colors.white)),
    );
  }

  Widget mnemonicView() {
    return Form(
        key: _formKey,
        child: Container(
            alignment: Alignment.centerLeft,
            child: Column(children: [
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 16.h, bottom: 16.h),
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
                controller: _keyCtrl,
                keyboardType: TextInputType.text,
                // onChanged: _onKeyChange,
              ),
            ])));
  }
}
