import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:polkawallet_sdk/api/types/addressIconData.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'dart:developer' as developer;

import 'package:polkawallet_sdk/storage/types/keyPairData.dart';

class WalletView2 extends StatefulWidget {
  WalletView2(this.sdk, this.keyring);

  final WalletSDK sdk;
  final Keyring keyring;

  static const String route = '/wallet2';

  @override
  State<WalletView2> createState() => _WalletView2State();
}

class _WalletView2State extends State<WalletView2> {
  bool _connecting = false;
  bool _apiConnected = false;
  final String _name = 'jacky';
  final String _testPass = 'a123456';
  final String _mnemonic =
      'shoe slow room wrist sibling pottery galaxy odor polar attend word fan';
  KeyPairData? _testAcc;
  int _ss58 = 42;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarView(),
      body: SafeArea(
          child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('js-api loaded: ${widget.sdkReady}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('js-api connected: $_apiConnected'),
                    OutlinedButton(
                      child: _connecting
                          ? CupertinoActivityIndicator()
                          : Text(_apiConnected ? 'connected' : 'connect'),
                      onPressed: _apiConnected || _connecting
                          ? null
                          : () => _connectNode(),
                    )
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('getAccountList'),
            subtitle: Text('''
sdk.api.keyring.accountList'''),
            trailing: IconButton(
              icon: Icon(Icons.play_circle_outline),
              onPressed: () {
                _getAccountList();
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text('generateMnemonic'),
            subtitle: Text('sdk.api.keyring.generateMnemonic()'),
            trailing: IconButton(
              icon: Icon(Icons.play_circle_outline),
              onPressed: () {
                _generateMnemonic();
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text('importFromMnemonic'),
            subtitle: Text('sdk.api.keyring.importAccount()'),
            trailing: IconButton(
              icon: Icon(Icons.play_circle_outline),
              onPressed: () {
                _importFromMnemonic();
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text('queryBalance'),
            subtitle: Text('sdk.api.account.queryBalance()'),
            trailing: IconButton(
              icon: Icon(Icons.play_circle_outline),
              onPressed: () {
                _queryBalance();
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text('sendTx'),
            subtitle: Text('sdk.api.tx.sendTx'),
            trailing: IconButton(
              icon: Icon(Icons.play_circle_outline),
              onPressed: () {
                _sendTx();
              },
            ),
          ),
          Divider(),
        ],
      )),
    );
  }

  PreferredSizeWidget getAppBarView() {
    return BrnAppBar(
      brightness: Brightness.light,
      toolbarOpacity: 1,
      bottomOpacity: 0,
      showDefaultBottom: false,
      backgroundColor: Colors.green,
      title: 'Wallet',
      actions: <Widget>[
        BrnIconAction(
          iconPressed: () {},
          child: Icon(Icons.settings),
        ),
      ],
    );
  }

  Future<void> _connectNode() async {
    setState(() {
      _connecting = true;
    });
    final node = NetworkParams();
    node.name = 'Polket';
    node.endpoint = 'wss://testnet-node.polket.io';
    node.ss58 = _ss58;
    final res = await widget.sdk.api.connectNode(widget.keyring, [node]);
    if (res != null) {
      setState(() {
        _apiConnected = true;
      });
    }
    setState(() {
      _connecting = false;
    });
  }

  Future<void> _getAccountList() async {
    widget.keyring.setSS58(_ss58);
    final List accs = widget.keyring.keyPairs;
    for (var acc in accs) {
      LogUtil.d('account: ${acc.name}: ${acc.address}');
      setState(() {
        _testAcc = acc;
      });
    }
  }

  Future<void> _generateMnemonic() async {
    widget.keyring.setSS58(_ss58);
    final AddressIconDataWithMnemonic seed =
        await widget.sdk.api.keyring.generateMnemonic(_ss58);
    LogUtil.d('mnemonic: ${seed.mnemonic ?? 'empty'} ');
  }

  Future<void> _importFromMnemonic() async {
    widget.keyring.setSS58(_ss58);
    final json = await widget.sdk.api.keyring.importAccount(
      widget.keyring,
      keyType: KeyType.mnemonic,
      key: _mnemonic,
      name: _name,
      password: _testPass,
    );
    final acc = await widget.sdk.api.keyring.addAccount(
      widget.keyring,
      keyType: KeyType.mnemonic,
      acc: json!,
      password: _testPass,
    );
    LogUtil.d('address: ${acc.address ?? 'empty'} ');
    setState(() {
      _testAcc = acc;
    });
  }

  Future<void> _queryBalance() async {
    // widget.sdk.api.
    final res = await widget.sdk.api.account.queryBalance(_testAcc!.address);
    LogUtil.d('balance: ${res!.freeBalance}');

  }

  Future<void> _sendTx() async {
    if (widget.keyring.keyPairs.length == 0) {
      return;
    }

    final sender = TxSenderData(
      widget.keyring.keyPairs[0].address,
      widget.keyring.keyPairs[0].pubKey,
    );
    final txInfo = TxInfoData('balances', 'transfer', sender);
    try {
      final hash = await widget.sdk.api.tx.signAndSend(
        txInfo,
        [
          // params.to
          // _testAddressGav,
          '5GKR5QGcwo4hh9EiwRbEGVn8czsPr3rFHevmSVzn6kqypGQu',
          // params.amount
          '50000000000'
        ],
        _testPass,
        onStatusChange: (status) {
          LogUtil.d(status);
          // setState(() {
          //   _status = status;
          // });
        },
      );
      LogUtil.d('sendTx txid: ${hash.toString()}');
    } catch (err) {
      LogUtil.d('sendTx failed: ${err.toString()}');
    }
  }

}
