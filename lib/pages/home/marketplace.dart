import 'package:bruno/bruno.dart';
import 'package:flukit/example/common/index.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_detail.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_grid_item.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/types/vfe_order.dart';

class MarketplaceView extends StatefulWidget {
  MarketplaceView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  @override
  State<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<MarketplaceView>
    with TickerProviderStateMixin {
  List<Order> _marketOrders = [];
  List<Order> _mySaleOrders = [];
  bool showMySales = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      refreshMarketOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      final marketOrders = widget.plugin.store.vfeOrder.marketOrders;
      final user = widget.keyring.current.address ?? '';
      _mySaleOrders = marketOrders.where((e) => e.owner == user).toList();
      _marketOrders = marketOrders.where((e) => e.owner != user).toList();
      List<Order> orders;
      if (showMySales) {
        orders = _mySaleOrders;
      } else {
        orders = _marketOrders;
      }
      return Container(
          color: Colors.white,
          child: PullRefreshScope(
              child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverPullRefreshIndicator(
                onRefresh: () async {
                  // await Future<void>.delayed(const Duration(seconds: 2));
                  await refreshMarketOrders();
                },
              ),
              SliverStickyHeader(
                  header: tabbarView(context),
                  sticky: true,
                  sliver: gridView(context, orders))
            ],
          )));
    });
  }

  Widget tabbarView(BuildContext context) {
    List<BadgeTab> tabs = [];
    tabs.add(BadgeTab(text: "Market"));
    tabs.add(BadgeTab(text: "My Sale", badgeNum: _mySaleOrders.length));
    TabController tabController =
        TabController(length: tabs.length, vsync: this);
    tabController.index = showMySales ? 1 : 0;
    return BrnTabBar(
      controller: tabController,
      tabs: tabs,
      hasDivider: true,
      onTap: (state, index) {
        setState(() {
          showMySales = index == 0 ? false : true;
        });
      },
    );
  }

  Widget gridView(BuildContext context, List<Order> orders) {
    Widget contentView;
    if (orders.isEmpty) {
      contentView = SliverFillViewport(
          viewportFraction: 1.0,
          delegate: SliverChildBuilderDelegate((context, index) {
            return const NoDataView();
          }));
    } else {
      contentView = SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final order = orders[index];
              final vfe = order.details.first;
              final asset =
                  widget.plugin.store.assets.getTokenByAssetId(order.assetId);
              final price = TokenBalanceData(
                  amount: order.price,
                  decimals: asset?.decimals,
                  symbol: asset?.symbol,
                  id: order.assetId.toString());
              return VFEGridItemView(vfe,
                  owned: showMySales,
                  scenario: VFEGridItemScenario.marketplace,
                  price: price,
                  orderId: order.id,
                  itemOnTap: gotoVFEDetailView,
                  buttonOnTap: handleOrder);
            },
            childCount: orders.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
        ),
      );
    }

    return SliverSafeArea(
      sliver: contentView,
    );
  }

  Future<void> refreshMarketOrders() async {
    final list = await widget.plugin.api.vfeOrder.getOrdersAll();
    list.sort((left, right) => right.id.compareTo(left.id));
    widget.plugin.store.vfeOrder.marketOrders.clear();
    widget.plugin.store.vfeOrder.marketOrders.addAll(list);
  }

  gotoVFEDetailView(VFEDetail vfe, TokenBalanceData? price, int? orderId) {
    Navigator.of(context).pushNamed(VFEDetailView.route, arguments: {
      'vfeDetail': vfe,
      'marketPrice': price,
      'orderId': orderId,
    });
  }

  handleOrder(VFEDetail vfe, TokenBalanceData? price, int? orderId) {
    final user = widget.keyring.current.address ?? '';
    if (user == vfe.owner) {
      confirmCancelOrder(vfe, price, orderId);
    } else {
      confirmTakeOrder(vfe, price, orderId);
    }
  }

  confirmCancelOrder(
      VFEDetail vfe, TokenBalanceData? price, int? orderId) async {
    if (orderId == null) {
      BrnToast.show('Order is not existed', context);
      return;
    }
    final password = await widget.plugin.api.account.getPassword(
      context,
      widget.keyring.current,
      true,
    );
    if (password == null) {
      return;
    }

    if (!mounted) return;
    BrnLoadingDialog.show(context,
        content: 'Processing...', barrierDismissible: false);

    final result =
        await widget.plugin.api.vfeOrder.removeOrder(orderId!, password);

    if (!result.success) {
      // update  state
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show(result.error, context);
    } else {
      await widget.plugin.loadUserVFEs(widget.keyring.current.pubKey!);
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show('Cancel order successfully', context);
      widget.plugin.store.vfeOrder.removeOrder(orderId!);
    }
  }

  confirmTakeOrder(VFEDetail vfe, TokenBalanceData? price, int? orderId) async {
    if (orderId == null) {
      BrnToast.show('Order is not existed', context);
      return;
    }
    final orderOwner = vfe.owner ?? '';
    final password = await widget.plugin.api.account.getPassword(
      context,
      widget.keyring.current,
      true,
    );
    if (password == null) {
      return;
    }

    if (!mounted) return;
    BrnLoadingDialog.show(context,
        content: 'Processing...', barrierDismissible: false);

    final result = await widget.plugin.api.vfeOrder
        .takeOrder(orderId!, orderOwner, password);

    if (!result.success) {
      // update  state
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show(result.error, context);
    } else {
      await widget.plugin.loadUserVFEs(widget.keyring.current.pubKey!);
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show('Take order successfully', context);
      widget.plugin.store.vfeOrder.removeOrder(orderId!);
    }
  }
}
