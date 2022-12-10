import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_selector.dart';
import 'package:toearnfun_flutter_app/pages/wallet/wallet.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class VFEDetailView extends StatefulWidget {
  VFEDetailView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/vfe/vfe_detail';

  @override
  State<VFEDetailView> createState() => _VFEDetailViewState();
}

class _VFEDetailViewState extends State<VFEDetailView> {
  final _backgroundColor = HexColor('#956DFD');
  final _roundColor = HexColor('#f9f7f7');

  VFEDetail? vfeDetail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      setState(() {
        vfeDetail = data["vfeDetail"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _roundColor,
        appBar: getAppBarView(context),
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                child: getBottomToolBarView(context))));
  }

  PreferredSizeWidget getAppBarView(BuildContext context) {
    return AppBar(
      leading: MyBackButton(),
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      title: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(WalletView.route);
          },
          icon: Image.asset('assets/images/Coin_FUN.png'),
          label:
              Text('0.0', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(WalletView.route);
          },
          icon: Image.asset('assets/images/Coin_PNT.png'),
          label:
              Text('0.0', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ]),
    );
  }

  Widget getTitleView() {
    return Container();
  }

  Widget getLevelView() {
    return Container();
  }

  Widget getVFEImageView() {
    return Container();
  }

  Widget getVFEAttributesView() {
    return Container();
  }

  Widget getBottomToolBarView(BuildContext context) {
    final isBond = (vfeDetail?.deviceKey ?? "").isEmpty ? false : true;
    final brandId = vfeDetail?.brandId ?? 0;
    final itemId = vfeDetail?.itemId ?? 0;
    String bindButton = isBond ? "Unbind" : "Bind";
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BrnIconButton(
              name: 'Level up',
              direction: Direction.bottom,
              padding: 4,
              widgetWidth: 75.w,
              widgetHeight: 75.h,
              iconWidget: Icon(Icons.arrow_upward),
              onTap: () {
                BrnToast.show('press', context);
              }),
          BrnIconButton(
              name: 'Charge',
              direction: Direction.bottom,
              padding: 4,
              widgetWidth: 75.w,
              widgetHeight: 75.h,
              iconWidget: Icon(Icons.arrow_upward),
              onTap: () {
                BrnToast.show('press', context);
              }),
          BrnIconButton(
              name: bindButton,
              direction: Direction.bottom,
              padding: 4,
              widgetWidth: 75.w,
              widgetHeight: 75.h,
              iconWidget: Icon(Icons.arrow_upward),
              onTap: () async {
                if (isBond) {
                  final password = await widget.plugin.api.account.getPassword(
                    context,
                    widget.keyring.current,
                  );
                  if (password != null) {
                    //unbind
                    final res = widget.plugin.api.vfe
                        .unbindDevice(brandId, itemId, password);
                    if (!mounted) return;
                    BrnToast.show("Unbind device successfully", context);
                  }
                } else {
                  //bind
                  BindDeviceSelector.showDeviceTypesSelector(context, itemId);
                }
              }),
          BrnIconButton(
              name: 'Sell',
              direction: Direction.bottom,
              padding: 4,
              widgetWidth: 75.w,
              widgetHeight: 75.h,
              iconWidget: Icon(Icons.arrow_upward),
              onTap: () {
                BrnToast.show('press', context);
              }),
          BrnIconButton(
              name: 'Transfer',
              direction: Direction.bottom,
              padding: 4,
              widgetWidth: 75.w,
              widgetHeight: 75.h,
              iconWidget: Icon(Icons.arrow_upward),
              onTap: () {
                BrnToast.show('press', context);
              }),
        ],
      ),
    );
  }

  Future<void> unbindDevice() async {}
}
