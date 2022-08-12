import 'dart:async';
import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class WalletView extends StatefulWidget {
  WalletView(this.sdk, this.keyring);

  final WalletSDK sdk;
  final Keyring keyring;

  static const String route = '/wallet';

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  @override
  void initState() {
    super.initState();
    //TODO: [check] Has a wallet been created? load assets:show dialog
    LogUtil.d('allAccounts: ${widget.keyring.allAccounts.length}');
    if (widget.keyring.allAccounts.length == 0) {
      // Timer(Duration(seconds: 1), () => showCreateWalletDialog());

      Future.delayed(Duration.zero, () {
        showCreateWalletDialog();
      });
    } else {
      //TODO: Show account assets
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBarView(),
        body: SafeArea(
            child: Column(children: [
          //[Main asset, Asset List]
          mainAssetView(context),
          TextButton(
              onPressed: () {
                showCreateWalletDialog();
                // Navigator.pop(context);
              },
              child: Text('click')),
        ])));
  }

  PreferredSizeWidget getAppBarView() {
    return BrnAppBar(
      brightness: Brightness.light,
      toolbarOpacity: 1,
      bottomOpacity: 0,
      showDefaultBottom: false,
      // backgroundColor: Colors.green,
      title: "Wallet",
      actions: <Widget>[
        BrnIconAction(
          iconPressed: () {},
          child: Icon(Icons.settings),
        ),
      ],
    );
  }

  // show user main asset view
  Widget mainAssetView(BuildContext context) {
    return Column(
      children: [
        //[Chain selector, Total Native token, address]
        TextButton.icon(
            onPressed: null,
            icon: Icon(Icons.arrow_drop_down),
            label: Text('Polket')),
        Text('200 PNT'),
        BrnIconButton(name: '0x1234abcd', iconWidget: Icon(Icons.link)),
      ],
    );
  }

  Widget assetsListView() {
    return ListView();
  }

  void showCreateWalletDialog() {
    BrnDialogManager.showMoreButtonDialog(context,
        actions: [
          'Create a new wallet',
          'Import a wallet using seed Phrase',
          'Exit',
        ],
        title: "Create Wallet", indexedActionClickCallback: (index) {
      Navigator.of(context).pop();
      if(index == 2) {
        _exit();
      }

    });
  }

  //exit this page
  void _exit() {
    Navigator.of(context).pop();
  }

  void createNewWallet() {

  }
}
