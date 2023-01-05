import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/plugin.dart';

class VFEChargeView extends StatefulWidget {
  VFEChargeView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  @override
  State<VFEChargeView> createState() => _VFEChargeViewState();
}

class _VFEChargeViewState extends State<VFEChargeView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        titleView(),
        vfeView(),
        chargeBarView(),
        bottomView(),
      ],
    ));
  }

  Widget titleView() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(),
        Text('Charge'),
        // IconButton(onPressed: null, icon: Icon(Icons.close)),
      ],
    ));
  }

  Widget vfeView() {
    return Container(
      alignment: Alignment.center,
      child: Image.asset('assets/images/vfe-card.png'),
    );
  }

  Widget chargeBarView() {
    return Container();
  }

  Widget bottomView() {
    return Container(
      child: Row(children: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'))
      ]),
    );
  }
}
