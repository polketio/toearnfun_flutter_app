import 'dart:async';
import 'package:bruno/bruno.dart';
import 'package:flukit/flukit.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/api/types/addressIconData.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/common/consts.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/service/app_service.dart';
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
  KeyPairData? currentAccount;

  double _initHeight = 180;

  @override
  void initState() {
    super.initState();
    // [check] Has a wallet been created? load assets:show dialog
    LogUtil.d('allAccounts: ${widget.keyring.allAccounts.length}');
    if (widget.keyring.allAccounts.length == 0) {
      Future.delayed(Duration.zero, () {
        showCreateWalletDialog();
      });
    } else {
      // show current account
      this.currentAccount = widget.keyring.current;
      LogUtil.d('current address: ${this.currentAccount!.address}');
    }
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      leading: MyBackButton(),
      // backgroundColor: Colors.green,
      title: Text('Wallet', style: TextStyle(color: Colors.white)),
      actions: <Widget>[
        IconButton(
            onPressed: null,
            icon: Image.asset('assets/images/icon-more.png'),
            iconSize: 36.w),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Scaffold(
          appBar: getAppBarView(),
          body: SafeArea(
              child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverFlexibleHeader(
                visibleExtent: _initHeight,
                builder: (context, availableHeight, direction) {
                  return mainAssetView(context);
                },
              ),
              SliverToBoxAdapter(
                child: ListTile(
                    onTap: null,
                    title: const Text('Assets'),
                    trailing: TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.history),
                      label: const Text('History',
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                    )),
              ),
              assetsListView(),
            ],
          )));
    });
  }

  // show user main asset view
  Widget mainAssetView(BuildContext context) {
    final symbol = (widget.plugin.networkState.tokenSymbol ?? [''])[0];
    final decimals =
        (widget.plugin.networkState.tokenDecimals ?? [12])[0];
    BalanceData? balancesInfo = widget.plugin.balances.native;
    return Container(
        decoration: new BoxDecoration(
          color: HexColor('#956DFD'),
        ),
        child: Column(
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
            Text(
              '${Fmt.balance(balancesInfo?.freeBalance, decimals)} $symbol',
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.w)),
                child: Padding(
                    padding: EdgeInsets.only(left: 8.w, right: 4.w),
                    child: BrnIconButton(
                      widgetWidth: 180.w,
                      widgetHeight: 34.w,
                      direction: Direction.right,
                      name: Fmt.address(
                          this.currentAccount?.address ?? "No Account"),
                      iconWidget: Image.asset('assets/images/icon-Connect.png'),
                      iconHeight: 28.w,
                      iconWidth: 28.w,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      style:
                          TextStyle(fontSize: 18, color: HexColor('#956DFD')),
                    ))),
          ],
        ));
  }

  // show currencies info
  Widget assetsListView() {

    List<TokenBalanceData> currencies = [];

    final nativeName = widget.plugin.networkState.name ?? "";
    final nativeSymbol =
    (widget.plugin.networkState.tokenSymbol ?? [''])[0];
    final nativeDecimals =
    (widget.plugin.networkState.tokenDecimals ?? [12])[0];
    final native = widget.plugin.balances.native;

    //add native
    currencies.add(TokenBalanceData(
        name: nativeName,
        symbol: nativeSymbol,
        decimals: nativeDecimals,
        amount: native?.freeBalance.toString()));

    final tokens = widget.plugin.balances.tokens;
    LogUtil.d('tokens count: ${tokens.length}');

    currencies.addAll(tokens);

    return SliverFixedExtentList(
      itemExtent: 82,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final d = currencies[index];
          return new Card(
              elevation: 0,
              margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
              color: HexColor('#e9e0ff'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.w)),
              child: ListTile(
                  // leading: Image.asset('assets/images/icon-${d.symbol}.png'),
                  leading: Image.asset('assets/images/icon-PNT.png'),
                  title: Text('${d.symbol}', style: TextStyle(fontSize: 18)),
                  subtitle: Text('${d.name}', style: TextStyle(fontSize: 12)),
                  trailing: Text('${Fmt.balance(d.amount, d.decimals ?? 12)}',
                      style: TextStyle(fontSize: 18)),
                  onTap: () => print(index)));
        },
        childCount: currencies.length,
      ),
    );
  }

  void showCreateWalletDialog() {
    BrnDialogManager.showMoreButtonDialog(context,
        barrierDismissible: false,
        actions: [
          'Create a new wallet',
          'Import a wallet using seed Phrase',
          'Exit',
        ],
        title: "Create Wallet", indexedActionClickCallback: (index) {
      Navigator.of(context).pop();
      if (index == 0) {
        // _generateAccount();
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

  // Future<void> _generateAccount({String key = ''}) async {
  //   // LogUtil.d('_generateAccount');
  //
  //   final addressInfo = await widget.service.plugin.sdk.api.keyring
  //       .generateMnemonic(widget.service.plugin.basic.ss58 ?? DEFAULT_SS58,
  //           key: key);
  //   LogUtil.d('mnemonic: ${addressInfo.mnemonic}');
  //   if (key.isEmpty && addressInfo.mnemonic != null) {
  //     widget.service.store.account.setNewAccountKey(addressInfo.mnemonic!);
  //     widget.service.store.account.setNewAccount('tester', '1234qwer');
  //
  //     try {
  //       final json = await widget.service.account.importAccount(
  //         isFromCreatePage: true,
  //       );
  //       await widget.service.account.addAccount(
  //         json: json,
  //         isFromCreatePage: true,
  //       );
  //
  //       widget.service.store.account.setAccountCreated();
  //
  //       setState(() {
  //         //update ui
  //         this.currentAccount = widget.service.keyring.current;
  //         LogUtil.d('current: ${widget.service.keyring.current.address}');
  //       });
  //     } catch (err) {
  //       LogUtil.e(err.toString());
  //     }
  //   }
  // }

  // load cureencies info, show [icon, symbol, name, amount]
  Future<void> loadCurrencies() async {
    // List<TokenBalanceData> currencies = [];

    // final data = await widget.plugin.sdk.api.account.queryBalance(widget.keyring.current.address);

    // await widget.service.plugin.updateBalances(widget.service.keyring.current);

    // final nativeName = widget.service.plugin.networkState.name ?? "";
    // final nativeSymbol =
    //     (widget.service.plugin.networkState.tokenSymbol ?? [''])[0];
    // final nativeDecimals =
    //     (widget.service.plugin.networkState.tokenDecimals ?? [12])[0];
    // final native = widget.service.plugin.balances.native;
    // LogUtil.d('native info: $native');

    // widget.plugin.balances.setBalance(data!);
    // widget.assets.getAllAssets();

    //TODO: add assets


    // final metadata = await widget.service.assets.queryMetaData(1);
    // LogUtil.d('metadata: ${metadata!.name}');

    // widget.service.store.assets.setTokenBalanceMap(currencies);
    // widget.service.plugin.balances.setTokens(currencies);
  }
}
