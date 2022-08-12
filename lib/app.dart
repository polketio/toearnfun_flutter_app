import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/pages/home/home.dart';
import 'package:toearnfun_flutter_app/pages/wallet/wallet.dart';
import 'package:toearnfun_flutter_app/pages/wallet/wallet2.dart';
import 'dart:developer' as developer;

import 'package:toearnfun_flutter_app/store/app_store.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

const get_storage_container = 'configuration';
const log_tag = 'ToEarnFun';

class ToEarnFunApp extends StatefulWidget {
  const ToEarnFunApp({Key? key}) : super(key: key);

  @override
  State<ToEarnFunApp> createState() => _ToEarnFunAppState();
}

class _ToEarnFunAppState extends State<ToEarnFunApp> {
  final WalletSDK sdk = WalletSDK();
  final Keyring keyring = Keyring();

  bool _sdkReady = false;

  Future<void> _initApi() async {
    LogUtil.init(tag: log_tag, isDebug: true);
    await keyring.init([0, 2, 42]);
    await sdk.init(keyring);
    final storage = GetStorage(get_storage_container);
    final store = AppStore(storage);
    await store.init();
    setState(() {
      _sdkReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _initApi();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844),
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ToEarnFun',
        theme: new ThemeData(
          primaryColor: Colors.white,
        ),
        home: new RootView(),
        routes: {
          WalletView.route: (_) =>
              WalletView(this.sdk, this.keyring),
          WalletView2.route: (_) =>
              WalletView2(this.sdk, this.keyring, this._sdkReady),
        },
      ),
    );
  }
}

class RootView extends StatefulWidget {
  const RootView({Key? key}) : super(key: key);

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: HexColor('#956DFD'),
      appBar: getAppBarView(context),
      bottomNavigationBar: getBottomTabBarView(),
      body: HomeView(),
    );
  }
}

PreferredSizeWidget getAppBarView(BuildContext context) {
  return AppBar(
    leadingWidth: 100.w,
    leading: IconButton(
      icon: Image.asset(
        'assets/images/home_icon_tl.png',
        width: 34.w,
      ),
      onPressed: null,
      alignment: Alignment.centerLeft,
    ),
    toolbarOpacity: 1,
    bottomOpacity: 0,
    elevation: 0,
    // showDefaultBottom: false,
    backgroundColor: HexColor('#956DFD'),
    title: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      TextButton.icon(
        // <-- TextButton
        onPressed: () {
          Navigator.of(context).pushNamed(WalletView2.route);
        },
        icon: Image.asset('assets/images/Coin_FUN.png', width: 34.w),
        label: Text('0.0', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      TextButton.icon(
        // <-- TextButton
        onPressed: () {
          Navigator.of(context).pushNamed(WalletView.route);
        },
        icon: Image.asset('assets/images/Coin_PNT.png', width: 34.w),
        label: Text('0.0', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    ]),
  );
}

Widget getBottomTabBarView() {
  return BottomAppBar(
      // elevation: 3.0,
      color: Colors.white,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Image.asset('assets/images/icon_AtTabBar_home-off.png'),
              onPressed: null,
            ),
            IconButton(
              icon:
                  Image.asset('assets/images/icon_AtTabBar_storehouse-off.png'),
              onPressed: null,
            ),
            IconButton(
              icon: Image.asset('assets/images/icon_AtTabBar_market-off.png'),
              onPressed: null,
            ),
          ]));
}
