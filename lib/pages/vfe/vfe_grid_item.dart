import 'dart:math';

import 'package:bruno/bruno.dart';
import 'package:ele_progress/ele_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_detail.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

enum VFEGridItemScenario {
  equipmentBag,
  marketplace,
}

class VFEGridItemView extends StatelessWidget {
  VFEGridItemView(this.vfe,
      {this.isEquipped = false,
      this.owned = false,
      this.scenario = VFEGridItemScenario.equipmentBag,
      this.price,
      this.orderId,
      this.itemOnTap,
      this.buttonOnTap});

  VFEDetail vfe;
  bool isEquipped;
  bool owned;
  VFEGridItemScenario scenario;
  Function(VFEDetail vfe, TokenBalanceData? price, int? orderId)? buttonOnTap;
  Function(VFEDetail vfe, TokenBalanceData? price, int? orderId)? itemOnTap;
  TokenBalanceData? price;
  int? orderId;

  final Color _commonBg = HexColor('#5D89F8');
  final Color _btnColor = HexColor('#C1F2EA');
  Color _borderColor = Colors.white.withOpacity(0.3);

  @override
  Widget build(BuildContext context) {
    if (isEquipped) {
      _borderColor = Colors.black.withOpacity(0.3);
    } else {
      _borderColor = Colors.white.withOpacity(0.3);
    }
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _commonBg,
            border: Border.all(color: _borderColor, width: 2.w),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: GestureDetector(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  itemIdView(vfe.itemId),
                  vfeImageView(vfe.rarity),
                  levelView(vfe.level, vfe.remainingBattery),
                  bottomView(),
                ]),
            onTap: () {
              if (itemOnTap != null) {
                itemOnTap!(vfe, price, orderId);
              }
            }));
  }

  Widget itemIdView(int? itemId) {
    return Container(
        margin: EdgeInsets.only(left: 34.w, right: 34.w),
        height: 28.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _borderColor,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8))),
        child: Text('#${itemId.toString().padLeft(4, '0')}',
            style: TextStyle(color: Colors.white, fontSize: 14)));
  }

  Widget vfeImageView(VFERarity rarity) {
    return Image.asset('assets/images/vfe-item-common-small.png');
  }

  Widget levelView(int level, int battery) {
    return Container(
        margin: EdgeInsets.only(left: 28.w, right: 28.w),
        alignment: Alignment.center,
        height: 30.h,
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lv ${vfe.level}',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text('$battery%',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 4.h)),
              SizedBox(
                  width: constraints.maxWidth,
                  height: 4.h,
                  child: EProgress(
                      progress: battery,
                      strokeWidth: 2,
                      showText: false,
                      colors: [HexColor('#b7e9e0')],
                      backgroundColor: Colors.grey)),
            ],
          );
        }));
  }

  Widget bottomView() {
    Widget controlWidget;
    if (scenario == VFEGridItemScenario.equipmentBag) {
      controlWidget = equipmentInfoView();
    } else {
      controlWidget = salesInfoView();
    }

    return Container(
        margin: EdgeInsets.zero,
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _borderColor,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6))),
        child: controlWidget);
  }

  Widget equipmentInfoView() {
    if (isEquipped) {
      return const Text('Equipped',
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold));
    } else {
      return BrnIconButton(
        name: 'Equip',
        direction: Direction.left,
        iconWidget: Icon(Icons.add, color: _btnColor),
        onTap: () {
          if (buttonOnTap != null) {
            buttonOnTap!(vfe, price, orderId);
          }
        },
        style: TextStyle(
            fontSize: 16, color: _btnColor, fontWeight: FontWeight.bold),
      );
    }
  }

  Widget salesInfoView() {
    Widget btnIcon;
    String btnTxt;
    if (owned) {
      btnIcon = Icon(Icons.close, color: _btnColor);
      btnTxt = 'Cancel';
    } else {
      btnIcon = Image.asset('assets/images/icon_AtTabBar_market-off.png');
      btnTxt = 'Buy';
    }

    final decimals = price?.decimals ?? 0;
    final symbol = price?.symbol ?? '';
    final priceTxt = '${Fmt.balance(price?.amount, decimals)} $symbol';
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 8.w, right: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(priceTxt,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
              flex: 1,
              child: BrnIconButton(
                name: btnTxt,
                direction: Direction.left,
                mainAxisAlignment: MainAxisAlignment.end,
                iconWidget: btnIcon,
                padding: 2,
                onTap: () {
                  if (buttonOnTap != null) {
                    buttonOnTap!(vfe, price, orderId);
                  }
                },
                style: TextStyle(
                    fontSize: 14,
                    color: _btnColor,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }
}

class AddVFEGridItemView extends StatelessWidget {
  AddVFEGridItemView({this.itemOnTap});

  Function()? itemOnTap;

  final Color _commonBg = HexColor('#c0a7fe');
  Color _borderColor = Colors.white.withOpacity(0.3);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: itemOnTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: _commonBg,
              border: Border.all(color: _borderColor, width: 2.w),
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          child: Image.asset('assets/images/icon-add-device-white.png'),
          // child: Icon(
          //   Icons.add,
          //   color: Colors.white,
          //   size: 50,
          // ),
        ));
  }
}
