import 'package:bruno/bruno.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_selector.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_detail.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_grid_item.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class EquipmentBagView extends StatefulWidget {
  EquipmentBagView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  @override
  State<EquipmentBagView> createState() => _EquipmentBagViewState();
}

class _EquipmentBagViewState extends State<EquipmentBagView> {
  List<VFEDetail> myVFEs = [];
  final _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: _backgroundColor,
        child: PullRefreshScope(
            child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPullRefreshIndicator(
              refreshTriggerPullDistance: 100.h,
              refreshIndicatorExtent: 60.h,
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 600));
                await refreshVFEList();
              },
            ),
            gridView(context)
          ],
        )));
  }

  Widget bannerView(BuildContext context) {
    return const Placeholder();
  }

  Widget gridView(BuildContext context) {
    return Observer(builder: (context) {
      final current = widget.plugin.store.vfe.current;
      myVFEs = widget.plugin.store.vfe.userVFEList;
      myVFEs.sort((left, right) => right.itemId!.compareTo(left.itemId!));
      return SliverSafeArea(
        sliver: SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index < myVFEs.length) {
                  bool isEquipped = false;
                  final vfe = myVFEs[index];
                  if (current.brandId == vfe.brandId &&
                      current.itemId == vfe.itemId) {
                    isEquipped = true;
                  }
                  return VFEGridItemView(vfe,
                      isEquipped: isEquipped,
                      itemOnTap: gotoVFEDetailView,
                      buttonOnTap: equipSelectedVFE);
                } else {
                  return AddVFEGridItemView(
                    itemOnTap: () {
                      BindDeviceSelector.showDeviceTypesSelector(
                          context, 0);
                    },
                  );
                }
              },
              childCount: myVFEs.length + 1,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
          ),
        ),
      );
    });
  }

  Future<void> refreshVFEList() async {
    final user = widget.keyring.current.pubKey;
    if (user != null) {
      await widget.plugin.loadUserVFEs(user);
    }
  }

  gotoVFEDetailView(VFEDetail vfe, TokenBalanceData? price, int? orderId) {
    Navigator.of(context).pushNamed(VFEDetailView.route, arguments: {
      'vfeDetail': vfe,
    });
  }

  equipSelectedVFE(VFEDetail vfe, TokenBalanceData? price, int? orderId) {
    BrnDialogManager.showConfirmDialog(context,
        title: "Equip VFE",
        cancel: 'Cancel',
        confirm: 'Confirm',
        message: "Do you want to replace your current VFE?",
        onConfirm: () async {
      Navigator.of(context).pop();
      await widget.plugin.store.vfe
          .updateUserCurrent(widget.keyring.current.pubKey, vfe);
    }, onCancel: () {
      Navigator.of(context).pop();
    });
  }
}
