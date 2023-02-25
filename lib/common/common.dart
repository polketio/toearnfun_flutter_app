import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/pages/wallet/wallet.dart';
import 'package:toearnfun_flutter_app/plugin.dart';

class MyBackButton extends StatelessWidget {
  MyBackButton({this.onBack, Key? key}) : super(key: key);

  final Function? onBack;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.of(context).pop();
          }
        },
        icon: Image.asset('assets/images/icon-L-Arrow.png'));
  }
}

class IconText extends StatelessWidget {
  IconText(this.icon, this.text, {TextStyle? this.style});

  String text;
  String icon;
  TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: null,
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        splashFactory: NoSplash.splashFactory,
        //disable click effect
        overlayColor: MaterialStateProperty.all(
            Colors.transparent), //disable click effect
      ),
      icon: Image.asset(icon),
      label: Text(text, style: style),
    );
  }
}

class AppBarTittleView extends StatelessWidget {
  const AppBarTittleView(this.plugin, {super.key});

  final PluginPolket plugin;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final decimals =
      (plugin.networkState.tokenDecimals ?? [12])[0];
      final native = plugin.balances.native;
      final tokens = plugin.store.assets.assetBalanceMap;
      final fun = tokens['FUN'];

      return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(WalletView.route);
          },
          icon: Image.asset('assets/images/Coin_FUN.png'),
          label: Text(Fmt.balance(fun?.amount, fun?.decimals ?? decimals, length: 2),
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(WalletView.route);
          },
          icon: Image.asset('assets/images/Coin_PNT.png'),
          label: Text(Fmt.balance(native?.freeBalance, decimals, length: 2),
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ]);
    });
  }
}

class NoDataView extends StatelessWidget {
  const NoDataView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BrnAbnormalStateWidget(
      isCenterVertical: true,
      img: Image.asset(
        'assets/images/no-data-available.png',
      ),
      content: 'No data available',
    );
  }
}
