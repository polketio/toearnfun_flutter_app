import 'dart:async';
import 'package:bruno/bruno.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/wallet/account/account_manage.dart';
import 'package:toearnfun_flutter_app/pages/wallet/buyback/buyback_plans.dart';
import 'package:toearnfun_flutter_app/pages/wallet/wallet_deposit.dart';
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
    _currentAccount = widget.keyring.current;
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(),
      centerTitle: true,
      title: const Text('Wallet', style: TextStyle(color: Colors.white)),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AccountManageView.route);
            },
            icon: Image.asset('assets/images/icon-more.png'),
            iconSize: 36.w),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
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
                maxHeight: 220.h,
                minHeight: 200.h,
                child: mainAssetView(context),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: SliverHeaderDelegate(
                  maxHeight: 60.h, minHeight: 60.h, child: assetsHeaderView()),
            ),
            assetsListView(),
          ],
        ))));
  }

  // show user main asset view
  Widget mainAssetView(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //[Chain selector, Total Native token, address]
            Container(
                height: 30.h,
                width: 80.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Text(
                  'Polket',
                  style: TextStyle(fontSize: 14, color: HexColor('#956dfd')),
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
            buttonsView(),
          ],
        ));
  }

  Widget assetsHeaderView() {
    return Stack(fit: StackFit.expand, children: [
      Container(
          decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: [
          BoxShadow(
            color: _backgroundColor,
            blurRadius: 0.0,
            spreadRadius: 0.0,
            offset: const Offset(0, -2),
          ),
        ],
      )),
      Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
              onTap: null,
              title: const Text('Assets'),
              trailing: TextButton.icon(
                onPressed: () {
                  BrnToast.show('Coming soon', context);
                },
                icon: const Icon(Icons.history),
                label: const Text('History',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ))),
    ]);
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
                    title: Text('${d.symbol}', style: TextStyle(fontSize: 18)),
                    subtitle: Text('${d.name}', style: TextStyle(fontSize: 12)),
                    trailing: Text(
                        '${Fmt.balance(d.amount, d.decimals ?? nativeDecimals)}',
                        style: TextStyle(fontSize: 18)),
                    onTap: () => print(index)));
          },
          childCount: currencies.length,
        ),
      );
    });
  }

  Widget buttonsView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BrnIconButton(
          name: 'Receive',
          direction: Direction.bottom,
          iconWidget: const Icon(
            Icons.call_received,
            color: Colors.white,
          ),
          style: const TextStyle(color: Colors.white),
          onTap: () {
            WalletDepositView.showDialogView(widget.keyring);
          },
        ),
        BrnIconButton(
          name: 'Transfer',
          direction: Direction.bottom,
          iconWidget: const Icon(Icons.call_made, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          onTap: () {
            BrnToast.show('Coming soon', context);
          },
        ),
        BrnIconButton(
          name: 'Trade',
          direction: Direction.bottom,
          iconWidget: Icon(Icons.repeat, color: Colors.white),
          style: TextStyle(color: Colors.white),
          onTap: () {
            Navigator.of(context).pushNamed(BuybackPlansView.route);
          },
        ),
      ],
    );
  }

  // load cureencies info, show [icon, symbol, name, amount]
  Future<void> loadCurrencies() async {
    final tokens = await widget.plugin.api.assets.getAllAssets();
    widget.plugin.balances.setTokens(tokens);
  }
}
