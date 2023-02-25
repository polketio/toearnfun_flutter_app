import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/buyback_plan.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class BuybackPlanItemView extends StatelessWidget {
  BuybackPlanItemView(this.data, this.plugin, {this.buttonOnTap})
      : sellAsset = plugin.store.assets.getTokenByAssetId(data.sellAssetId),
        buyAsset = plugin.store.assets.getTokenByAssetId(data.buyAssetId);

  Function(BuyBackPlan plan)? buttonOnTap;
  BuyBackPlan data;
  PluginPolket plugin;
  TokenBalanceData? sellAsset;
  TokenBalanceData? buyAsset;

  final _btnColor = HexColor('#8953ED');
  final _labelStyle = TextStyle(fontSize: 12, color: HexColor('#8953ED'));
  final _valueStyle = const TextStyle(fontSize: 20, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        margin:
            EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w, bottom: 12.h),
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
        child: GestureDetector(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            titleView(),
            contentView(),
            bottomView(),
          ],
        )));
  }

  Widget titleView() {
    Color statusBgColor;
    String statusName = data.status;
    switch (PlanStatus.values.byName(data.status)) {
      case PlanStatus.Upcoming:
        statusBgColor = Colors.orange;
        break;
      case PlanStatus.InProgress:
        statusBgColor = Colors.green;
        break;
      case PlanStatus.Completed:
      case PlanStatus.AllPaybacked:
        statusBgColor = _btnColor;
        statusName = PlanStatus.Completed.name;
        break;
    }

    String buyAssetImg = buyAsset != null
        ? 'assets/images/icon-${buyAsset!.symbol}.png'
        : 'assets/images/icon-KSM.png';
    String sellAssetImg = sellAsset != null
        ? 'assets/images/icon-${sellAsset!.symbol}.png'
        : 'assets/images/icon-KSM.png';
    return Container(
        padding: EdgeInsets.only(top: 12.h, left: 12.w),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          //coin-pair, status
          SizedBox(
            height: 41.h,
            width: 82.w,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.asset(buyAssetImg),
                Positioned(
                  child: Image.asset(sellAssetImg, scale: 3),
                  left: 25,
                ),
              ],
            ),
          ),

          Card(
              margin: EdgeInsets.zero,
              color: statusBgColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.w),
                      bottomLeft: Radius.circular(18.w))),
              child: Container(
                  alignment: Alignment.center,
                  height: 36.h,
                  padding: EdgeInsets.fromLTRB(16.w, 0, 8.w, 0),
                  child: Text(
                    statusName,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ))),
        ]));
  }

  Widget contentView() {
    final sellAssetDecimals = sellAsset?.decimals ?? 0;
    final buyAssetDecimals = buyAsset?.decimals ?? 0;
    final totalBuy = Fmt.balanceDouble(data?.totalBuy ?? '0', buyAssetDecimals);
    final totalSell =
        Fmt.balanceDouble(data?.totalSell ?? '0', buyAssetDecimals);
    String price;
    if (totalBuy > 0 && totalSell > 0) {
      price = Fmt.doubleFormat(totalSell / totalBuy);
    } else {
      price = '??';
    }

    return Container(
        padding: EdgeInsets.only(left: 12.w, right: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Rewards, Price
                    dataItemView('${buyAsset?.symbol} Rewards',
                        Fmt.balance(data?.totalBuy, buyAssetDecimals)),
                    Padding(padding: EdgeInsets.only(top: 12.h)),
                    dataItemView(
                        'Price of ${sellAsset?.symbol}/${buyAsset?.symbol}',
                        price),
                  ],
                )),
            Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Locked, Participants
                    dataItemView('${sellAsset?.symbol} Locked',
                        Fmt.balance(data?.totalSell, sellAssetDecimals)),
                    Padding(padding: EdgeInsets.only(top: 12.h)),
                    dataItemView('Participants', data.sellerAmount.toString()),
                  ],
                ))
          ],
        ));
  }

  Widget dataItemView(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _labelStyle),
        Text(
          value,
          style: _valueStyle,
        ),
      ],
    );
  }

  Widget bottomView() {
    return Observer(builder: (_) {
      final start = data.start;
      final end = data.start + data.period;
      final currentHeight = plugin.store.system.currentBlockNumber;
      final expectedBlockTime = plugin.api.system.expectedBlockTime / 1000;
      String remainingTime = '';
      switch (PlanStatus.values.byName(data.status)) {
        case PlanStatus.Upcoming:
          final remainingSeconds =
              (start - currentHeight) * expectedBlockTime.round();
          remainingTime = 'Starts in: ${formatTime(remainingSeconds)}';
          break;
        case PlanStatus.InProgress:
          final remainingSeconds =
              (end - currentHeight) * expectedBlockTime.round();
          remainingTime = 'Ends in: ${formatTime(remainingSeconds)}';
          break;
        case PlanStatus.Completed:
        case PlanStatus.AllPaybacked:
          final remainingSeconds =
              (currentHeight - end) * expectedBlockTime.round();
          remainingTime = 'Ended: ${formatTime(remainingSeconds)} ago';
          break;
      }

      List<Widget> children = [
        Text(remainingTime,
            style: TextStyle(fontSize: 18, color: Colors.green)),
      ];
      if (buttonOnTap != null) {
        children.add(SizedBox(
            height: 36.h,
            child: BrnSmallMainButton(
              radius: 18,
              bgColor: _btnColor,
              textColor: Colors.white,
              title: 'View',
              onTap: () {
                buttonOnTap!(data);
              },
            )));
      }

      return Container(
          // color: HexColor('#F3F5FC'),
          decoration: BoxDecoration(
            color: HexColor('#F3F5FC'),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10.w)),
          ),
          height: 55.h,
          padding: EdgeInsets.only(left: 12.w, right: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ));
    });
  }

  String formatTime(int s) {
    final duration = Duration(seconds: s);
    String days = duration.inDays.toString();
    String hours = duration.inHours.remainder(24).toString();
    String minutes = (duration.inMinutes.remainder(60) + 1).toString();
    return '${days}days ${hours}h ${minutes}min';
  }
}
