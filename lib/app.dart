import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:toearnfun_flutter_app/pages/home/home.dart';

class RootView extends StatefulWidget {
  const RootView({Key? key}) : super(key: key);

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: getAppBarView(),
      bottomNavigationBar: getBottomTabBarView(),
      body: HomeView(),
    );
  }
}

PreferredSizeWidget getAppBarView() {
  return BrnAppBar(
    //自定义左侧icon
    leading: new Icon(Icons.face, color: Colors.black),
    brightness: Brightness.light,
    toolbarOpacity: 1,
    bottomOpacity: 0,
    showDefaultBottom: false,
    backgroundColor: Colors.green,
    actions: <Widget>[
      BrnIconButton(
        name: "10.00",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        iconWidget: Icon(Icons.currency_bitcoin),
        direction: Direction.left,
      ),
      BrnIconButton(
        name: "10.00",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        iconWidget: Icon(Icons.currency_yen),
        direction: Direction.left,
      )
    ],
  );
}

Widget getBottomTabBarView() {
  return BrnBottomTabBar(
    fixedColor: Colors.blue,
    currentIndex: 0,
    onTap: (_) {},
    badgeColor: Colors.red,
    items: <BrnBottomTabBarItem>[
      BrnBottomTabBarItem(
          icon: new Icon(Icons.home),
          activeIcon: new Icon(Icons.home_outlined),
          title: Text("Home")),
      BrnBottomTabBarItem(
          icon: new Icon(Icons.wallet),
          activeIcon: new Icon(Icons.wallet_outlined),
          title: Text("VFE")),
      BrnBottomTabBarItem(
          icon: new Icon(Icons.store),
          activeIcon: new Icon(Icons.store_outlined),
          title: Text("Market")),
    ],
  );
}
