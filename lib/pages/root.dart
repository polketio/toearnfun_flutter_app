import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/home/equipment_bag.dart';
import 'package:toearnfun_flutter_app/pages/home/home.dart';
import 'package:toearnfun_flutter_app/pages/home/marketplace.dart';
import 'package:toearnfun_flutter_app/pages/profile/profile.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class RootView extends StatefulWidget {
  RootView(this.plugin, this.keyring) {
    bottomBarViews = [
      HomeView(plugin, keyring),
      EquipmentBagView(plugin, keyring),
      MarketplaceView(),
    ];
  }

  PluginPolket plugin;
  Keyring keyring;
  late List<Widget> bottomBarViews;

  static final String route = '/toearnfun/root';

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#956DFD'),
      appBar: getAppBarView(context),
      bottomNavigationBar: getBottomTabBarView(),
      body: widget.bottomBarViews[selectedIndex],
    );
  }

  PreferredSizeWidget getAppBarView(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Image.asset(
          'assets/images/home_icon_tl.png',
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(ProfileView.route);
        },
        alignment: Alignment.centerLeft,
      ),
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      title: AppBarTittleView(widget.plugin),
    );
  }

  Widget getBottomTabBarView() {
    return BottomAppBar(
        // elevation: 3.0,
        color: Colors.white,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <
            Widget>[
          IconButton(
            icon: selectedIndex == 0
                ? Image.asset('assets/images/icon_AtTabBar_home-on.png')
                : Image.asset('assets/images/icon_AtTabBar_home-off.png'),
            onPressed: () {
              changeTabView(0);
            },
          ),
          IconButton(
            icon: selectedIndex == 1
                ? Image.asset('assets/images/icon_AtTabBar_storehouse-on.png')
                : Image.asset('assets/images/icon_AtTabBar_storehouse-off.png'),
            onPressed: () {
              changeTabView(1);
            },
          ),
          IconButton(
            icon: selectedIndex == 2
                ? Image.asset('assets/images/icon_AtTabBar_market-on.png')
                : Image.asset('assets/images/icon_AtTabBar_market-off.png'),
            onPressed: () {
              changeTabView(2);
            },
          ),
        ]));
  }

  changeTabView(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
