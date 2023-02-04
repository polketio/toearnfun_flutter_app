import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_grid_item.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

class EquipmentBagView extends StatefulWidget {
  EquipmentBagView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  @override
  State<EquipmentBagView> createState() => _EquipmentBagViewState();
}

class _EquipmentBagViewState extends State<EquipmentBagView> {
  List<VFEDetail> myVFEs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: PullRefreshScope(
            child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPullRefreshIndicator(
              refreshTriggerPullDistance: 100.h,
              refreshIndicatorExtent: 60.h,
              onRefresh: () async {},
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
      myVFEs = widget.plugin.store.vfe.userVFEList;
      myVFEs.sort((left, right) => right.itemId!.compareTo(left.itemId!));
      return SliverSafeArea(
        sliver: SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return VFEGridItemView(myVFEs[index]);
              },
              childCount: myVFEs.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
          ),
        ),
      );
    });
  }
}
