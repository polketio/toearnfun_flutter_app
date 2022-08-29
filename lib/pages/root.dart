import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/pages/home/home.dart';
import 'package:toearnfun_flutter_app/pages/wallet/wallet.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class RootView extends StatefulWidget {
  RootView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static final String route = '/toearnfun/root';

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
      body: HomeView(widget.plugin, widget.keyring),
    );
  }
}

PreferredSizeWidget getAppBarView(BuildContext context) {
  return AppBar(
    leading: IconButton(
      icon: Image.asset(
        'assets/images/home_icon_tl.png',
      ),
      onPressed: null,
      alignment: Alignment.centerLeft,
    ),
    toolbarOpacity: 1,
    bottomOpacity: 0,
    elevation: 0,
    backgroundColor: HexColor('#956DFD'),
    title: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      TextButton.icon(
        // <-- TextButton
        onPressed: () {
          Navigator.of(context).pushNamed(WalletView.route);
        },
        icon: Image.asset('assets/images/Coin_FUN.png'),
        label: Text('0.0', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      TextButton.icon(
        // <-- TextButton
        onPressed: () {
          Navigator.of(context).pushNamed(WalletView.route);
        },
        icon: Image.asset('assets/images/Coin_PNT.png'),
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
