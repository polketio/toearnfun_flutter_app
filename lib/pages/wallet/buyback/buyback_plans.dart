import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/wallet/buyback/buyback_plan_detail.dart';
import 'package:toearnfun_flutter_app/pages/wallet/buyback/buyback_plan_item.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/buyback_plan.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class BuybackPlansView extends StatefulWidget {
  const BuybackPlansView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/buyback';

  @override
  State<BuybackPlansView> createState() => _BuybackPlansViewState();
}

class _BuybackPlansViewState extends State<BuybackPlansView> {
  List<BuyBackPlan> _buyBackPlansList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadBuybackPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor('#956DFD'),
        appBar: getAppBarView(context),
        body: SafeArea(
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
                // loadJumpRopeTrainingReport();
                loadBuybackPlans();
              },
            ),
            buybackPlansView(),
          ],
        ))));
  }

  PreferredSizeWidget getAppBarView(BuildContext context) {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      leading: MyBackButton(),
      centerTitle: true,
      title: Text('Buyback Plans', style: TextStyle(color: Colors.white)),
    );
  }

  Widget buybackPlansView() {
    return SliverFixedExtentList(
      itemExtent: 260.h,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final d = _buyBackPlansList[index];
          return BuybackPlanItemView(
            d,
            widget.plugin,
            buttonOnTap: (plan) {
              Navigator.of(context)
                  .pushNamed(BuybackPlanDetailView.route, arguments: {
                'planId': d.id,
              });
            },
          );
        },
        childCount: _buyBackPlansList.length,
      ),
    );
  }

  Future<void> loadBuybackPlans() async {
    final list = await widget.plugin.api.buyback.getBuybackPlans();
    setState(() {
      _buyBackPlansList = list;
      _buyBackPlansList.sort((left, right) => right.id.compareTo(left.id));
    });
  }
}
