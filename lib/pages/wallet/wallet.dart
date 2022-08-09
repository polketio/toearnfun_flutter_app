import 'package:flutter/cupertino.dart';

class WalletView extends StatefulWidget {
  const WalletView({Key? key}) : super(key: key);

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [
      //[Main asset, Asset List]
    ]));
  }

  // show user main asset view
  Widget mainAssetView() {
    return Container();
  }

  Widget AssetsListView() {
    return ListView();
  }
}
