import 'dart:async';
import 'package:bruno/bruno.dart';
import 'package:flukit/flukit.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/consts.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/welcome.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class WalletView extends StatefulWidget {
  WalletView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet';

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  KeyPairData? _currentAccount;

  final _backgroundColor = HexColor('#956DFD');

  @override
  void initState() {
    super.initState();
    LogUtil.d('allAccounts: ${widget.keyring.allAccounts.length}');
    _currentAccount = widget.keyring.current;
    LogUtil.d('_currentAccount: ${_currentAccount?.address}');
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(),
      centerTitle: true,
      title: Text('Wallet', style: TextStyle(color: Colors.white)),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              // Navigator.of(context).pushNamed(NewWalletWelcomeView.route);
            },
            icon: Image.asset('assets/images/icon-more.png'),
            iconSize: 36.w),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: getAppBarView(),
        body: SafeArea(
            child: PullRefreshScope(
                child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPullRefreshIndicator(
              refreshTriggerPullDistance: 100.h,
              refreshIndicatorExtent: 60.h,
              onRefresh: loadCurrencies,
            ),
            SliverPersistentHeader(
              delegate: SliverHeaderDelegate(
                maxHeight: 180.h,
                minHeight: 134.h,
                child: mainAssetView(context),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: SliverHeaderDelegate(
                  maxHeight: 60.h,
                  minHeight: 60.h,
                  child: Stack(fit: StackFit.expand, children: [
                    Container(
                        decoration: new BoxDecoration(
                      color: _backgroundColor,
                    )),
                    Container(
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: ListTile(
                            onTap: null,
                            title: const Text('Assets'),
                            trailing: TextButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.history),
                              label: const Text('History',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16)),
                            ))),
                  ])),
            ),
            assetsListView(),
          ],
        ))));
  }

  // show user main asset view
  Widget mainAssetView(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
          color: _backgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //[Chain selector, Total Native token, address]
            Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.w)),
                child: BrnIconButton(
                  name: 'Polket',
                  iconWidget: Image.asset('assets/images/icon-DownArrow.png'),
                  direction: Direction.right,
                  widgetWidth: 110.w,
                  widgetHeight: 34.h,
                  onTap: () {},
                  style: TextStyle(
                      fontSize: 16,
                      color: HexColor('#956dfd'),
                      fontWeight: FontWeight.bold),
                )),
            SizedBox(
                height: 34.h,
                child: Observer(builder: (_) {
                  final symbol =
                      (widget.plugin.networkState.tokenSymbol ?? [''])[0];
                  final decimals =
                      (widget.plugin.networkState.tokenDecimals ?? [12])[0];
                  BalanceData? balancesInfo = widget.plugin.balances.native;
                  return Text(
                    '${Fmt.balance(balancesInfo?.freeBalance, decimals)} $symbol',
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  );
                })),
            Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.w)),
                child: Padding(
                    padding: EdgeInsets.only(left: 8.w, right: 4.w),
                    child: BrnIconButton(
                      widgetWidth: 200.w,
                      widgetHeight: 34.w,
                      direction: Direction.right,
                      name:
                          Fmt.address(_currentAccount?.address ?? 'No Account'),
                      iconWidget: Image.asset('assets/images/icon-Connect.png'),
                      iconHeight: 28.w,
                      iconWidth: 28.w,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      style:
                          TextStyle(fontSize: 18, color: HexColor('#956DFD')),
                      onTap: () async {
                        Clipboard.setData(
                            ClipboardData(text: _currentAccount?.address));
                        BrnToast.show('Copied', context);
                      },
                    ))),
          ],
        ));
  }

  // show currencies info
  Widget assetsListView() {
    return Observer(builder: (_) {
      List<TokenBalanceData> currencies = [];
      final nativeSymbol = (widget.plugin.networkState.tokenSymbol ?? [''])[0];
      final nativeDecimals =
          (widget.plugin.networkState.tokenDecimals ?? [12])[0];
      final native = widget.plugin.balances.native;

      final tokens = widget.plugin.balances.tokens;

      currencies.addAll(tokens);

      return SliverFixedExtentList(
        itemExtent: 82,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final d = currencies[index];
            if (d.symbol == nativeSymbol) {
              d.amount = native?.freeBalance;
            }
            return Card(
                elevation: 0,
                margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
                color: HexColor('#e9e0ff'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w)),
                child: ListTile(
                    leading: Image.asset('assets/images/icon-${d.symbol}.png'),
                    // leading: Image.asset('assets/images/icon-PNT.png'),
                    title: Text('${d.symbol}', style: TextStyle(fontSize: 18)),
                    subtitle: Text('${d.name}', style: TextStyle(fontSize: 12)),
                    trailing: Text('${Fmt.balance(d.amount, d.decimals ?? nativeDecimals)}',
                        style: TextStyle(fontSize: 18)),
                    onTap: () => print(index)));
          },
          childCount: currencies.length,
        ),
      );
    });
  }

  void showCreateWalletDialog() {
    BrnDialogManager.showMoreButtonDialog(context,
        barrierDismissible: false,
        actions: [
          'Create a new wallet',
          'Import a wallet using seed Phrase',
          'Exit',
        ],
        title: 'Create Wallet', indexedActionClickCallback: (index) {
      Navigator.of(context).pop();
      if (index == 0) {
        _generateAccount();
      }
      if (index == 2) {
        _exit();
      }
    });
  }

  //exit this page
  void _exit() {
    Navigator.of(context).pop();
  }

  Future<void> _generateAccount({String key = ''}) async {
    // LogUtil.d('_generateAccount');

    final addressInfo = await widget.plugin.sdk.api.keyring
        .generateMnemonic(widget.plugin.basic.ss58 ?? DEFAULT_SS58, key: key);
    LogUtil.d('mnemonic: ${addressInfo.mnemonic}');
    if (key.isEmpty && addressInfo.mnemonic != null) {
      const password = '1234qwer';
      widget.plugin.store.account.setNewAccountKey(addressInfo.mnemonic!);
      widget.plugin.store.account.setNewAccount('tester', password);

      try {
        final json = await widget.plugin.api.account.importAccount(
          isFromCreatePage: true,
        );
        await widget.plugin.api.account.addAccount(
          json: json,
          isFromCreatePage: true,
        );
        final pubKey = json['pubKey'] ?? '';
        await widget.plugin.store.account.saveUserWalletPassword(pubKey, password);
        widget.plugin.store.account.setAccountCreated();

        setState(() {
          //update ui
          this._currentAccount = widget.keyring.current;
          LogUtil.d('current: ${widget.keyring.current.address}');
        });
      } catch (err) {
        LogUtil.e(err.toString());
      }
    }
  }

  // load cureencies info, show [icon, symbol, name, amount]
  Future<void> loadCurrencies() async {
    final tokens = await widget.plugin.api.assets.getAllAssets();
    widget.plugin.balances.setTokens(tokens);
  }

  Future<void> _sendTx(String address, String amount) async {
    if (widget.keyring.keyPairs.length == 0) {
      return;
    }

    final sender = TxSenderData(
      widget.keyring.current.address,
      widget.keyring.current.pubKey,
    );
    final txInfo = TxInfoData('balances', 'transfer', sender);
    try {
      final hash = await widget.plugin.sdk.api.tx.signAndSend(
        txInfo,
        [
          // params.to
          // _testAddressGav,
          address,
          // params.amount
          amount
        ],
        '1234qwer',
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
