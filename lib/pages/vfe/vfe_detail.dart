import 'package:bruno/bruno.dart';
import 'package:ele_progress/ele_progress.dart';
import 'package:flustars/flustars.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_selector.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_add_point.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_charge.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_grid_item.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_level_up.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_sell.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_transfer.dart';

import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_brand.dart';
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
  final _outlineBtnColor = HexColor('#a1d3c9');
  final _baseBtnBgColor = Colors.black45;

  VFEDetail? vfeDetail;
  TokenBalanceData? marketPrice;
  int? orderId;
  bool showBaseAbility = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      setState(() {
        vfeDetail = data['vfeDetail'];
        marketPrice = data['marketPrice'];
        orderId = data['orderId'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: getAppBarView(context),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      getTitleView(context),
                      getLevelView(context),
                      getVFEImageView(context),
                      Expanded(child: getVFEAttributesView(context), flex: 1),
                      getBottomToolBarView(context),
                    ]))));
  }

  PreferredSizeWidget getAppBarView(BuildContext context) {
    return AppBar(
      leading: MyBackButton(),
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      title: AppBarTittleView(widget.plugin),
    );
  }

  Widget getTitleView(BuildContext context) {
    final detail = vfeDetail ?? VFEDetail();
    final sportType = detail.getBrandInfo()?.sportType ?? SportType.JumpRope;
    final itemId = 'ID #${detail.itemId.toString().padLeft(4, '0')}';
    final rarity = detail.rarity;
    return Container(
      margin: EdgeInsets.only(left: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //[SportType, ID]
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(sportType.display.toUpperCase(),
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: HexColor('#8953ED'),
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  )),
              Text(
                itemId,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          // rarity
          Card(
              margin: EdgeInsets.zero,
              color: HexColor('#8953ED'),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(26.w),
                      bottomLeft: Radius.circular(26.w))),
              child: Container(
                  alignment: Alignment.center,
                  height: 52.h,
                  padding: EdgeInsets.fromLTRB(26.w, 0, 26.w, 0),
                  child: Text(
                    rarity.name,
                    style: GoogleFonts.zenDots(
                        textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                    )),
                  ))),
        ],
      ),
    );
  }

  Widget getLevelView(BuildContext context) {
    final detail = vfeDetail ?? VFEDetail();
    final level = detail.level;
    final battery = detail.remainingBattery;
    return Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //[level bar, battery bar]
              SizedBox(
                height: 26.h,
                width: double.infinity,
                child: EProgress(
                    progress: (level + 1) * 3,
                    showText: true,
                    textInside: true,
                    strokeWidth: 26.h,
                    type: ProgressType.line,
                    colors: [HexColor('#d08deb'), _backgroundColor],
                    backgroundColor: Colors.white,
                    textStyle:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    format: (percentage) {
                      return 'Lv. $level';
                    }),
              ),
              Padding(padding: EdgeInsets.only(top: 12.h)),
              SizedBox(
                  height: 26.h,
                  width: double.infinity,
                  child: EProgress(
                      progress: battery,
                      showText: true,
                      textInside: true,
                      strokeWidth: 26.h,
                      colors: [HexColor('#d08deb'), _backgroundColor],
                      backgroundColor: Colors.white,
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 12),
                      format: (percentage) {
                        return 'Battery $battery%';
                      })),
            ],
          ),
        ));
  }

  Widget getVFEImageView(BuildContext context) {
    String vfeImage = 'assets/images/vfe-card.png';
    return Container(
        child: Padding(
            padding: EdgeInsets.only(
                left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
            child: Image.asset(vfeImage)));
  }

  Widget getVFEAttributesView(BuildContext context) {
    final detail = vfeDetail ?? VFEDetail();
    final base = detail.baseAbility;
    final current = detail.currentAbility;

    Color stripeColor;
    int max = current.efficiency;
    if (current.skill > max) {
      max = current.skill;
    }
    if (current.luck > max) {
      max = current.luck;
    }
    if (current.durable > max) {
      max = current.durable;
    }

    int efficiency, skill, luck, durable;
    if (showBaseAbility) {
      efficiency = base.efficiency;
      skill = base.skill;
      luck = base.luck;
      durable = base.durable;
      stripeColor = _baseBtnBgColor;
    } else {
      efficiency = current.efficiency;
      skill = current.skill;
      luck = current.luck;
      durable = current.durable;
      stripeColor = _backgroundColor;
    }

    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(16.h),
        child: Column(
          children: [
            getAttributesTitleView(context),
            Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      getAttributesItemView('assets/images/icon-Efficiency.png',
                          stripeColor, 'Efficiency', efficiency, max),
                      getAttributesItemView('assets/images/icon-Speed-ab.png',
                          stripeColor, 'Skill', skill, max),
                      getAttributesItemView('assets/images/icon-Luck.png',
                          stripeColor, 'Luck', luck, max),
                      getAttributesItemView('assets/images/icon-Resilience.png',
                          stripeColor, 'Durable', durable, max),
                    ]))
          ],
        ));
  }

  Widget getAttributesTitleView(BuildContext context) {
    List<Widget> extWidgets = [];
    Widget baseBtn;
    if (showBaseAbility) {
      baseBtn = BrnSmallMainButton(
        radius: 18,
        title: 'Base',
        bgColor: _baseBtnBgColor,
        onTap: () {
          setState(() {
            showBaseAbility = false;
          });
        },
      );
    } else {
      baseBtn = BrnSmallOutlineButton(
        radius: 18,
        title: 'Base',
        lineColor: _outlineBtnColor,
        textColor: _outlineBtnColor,
        onTap: () {
          setState(() {
            showBaseAbility = true;
          });
        },
      );
    }

    // view is not use for market
    if (marketPrice == null) {
      final addPointBtn = SizedBox(
          height: 36.h,
          child: BrnSmallMainButton(
            radius: 18,
            bgColor: _outlineBtnColor,
            title: '+ Point',
            onTap: () async {
              final updated = await Navigator.of(context)
                  .pushNamed(VFEAddPointView.route, arguments: {
                'vfeDetail': vfeDetail,
              });
              if (updated != null) {
                setState(() {});
              }
            },
          ));
      extWidgets.add(Padding(padding: EdgeInsets.only(left: 8.w)));
      extWidgets.add(addPointBtn);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: Text(
              'Attributes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            flex: 1),
        SizedBox(height: 36.h, child: baseBtn),
        ...extWidgets,
      ],
    );
  }

  Widget getAttributesItemView(
      String icon, Color color, String text, int amount, int max) {
    double progress = 0;
    if (max > 0) {
      progress = amount * 100 / max;
    }
    return SizedBox(
        width: double.infinity,
        height: 32.h,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //[icon, text, bar, number]
              // IconText(icon, text),
              BrnIconButton(
                name: text,
                style: TextStyle(fontSize: 16),
                direction: Direction.left,
                padding: 4,
                iconWidget: Image.asset(icon),
                widgetHeight: 30.h,
                widgetWidth: 100.w,
                iconHeight: 16.h,
                iconWidth: 16.w,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              Expanded(
                  child: EProgress(
                      progress: progress.toInt(),
                      showText: false,
                      strokeWidth: 10.h,
                      colors: [color],
                      backgroundColor: HexColor('#f0f0f0')),
                  flex: 1),
              Padding(padding: EdgeInsets.only(left: 12.w)),
              SizedBox(
                width: 32.w,
                child: Text(
                  '$amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ]));
  }

  Widget getBottomToolBarView(BuildContext context) {
    if (marketPrice == null) {
      return userToolbarView();
    } else {
      return marketToolbarView(marketPrice!);
    }
  }

  Widget userToolbarView() {
    final isBond = (vfeDetail?.deviceKey ?? '').isEmpty ? false : true;
    final brandId = vfeDetail?.brandId ?? 0;
    final itemId = vfeDetail?.itemId ?? 0;
    String bindButton = isBond ? 'Unbind' : 'Bind';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 0.0,
            spreadRadius: 0.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 30.h),
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(builder: (context, constraints) {
        final btnWidth = constraints.maxWidth / 5 * 0.85;
        final size = Size(btnWidth, btnWidth);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            getToolbarItemView(
                context, size, 'assets/images/icon-Levelup-on.png', 'Level up',
                onTap: () {
              if (vfeDetail != null) {
                VFELevelUpView.showDialogView(
                    widget.plugin, widget.keyring, vfeDetail!,
                    doConfirm: doConfirmLevelUp);
              }
            }),
            getToolbarItemView(
                context, size, 'assets/images/icon-Charge-on.png', 'Charge',
                onTap: () {
              if (vfeDetail != null) {
                VFEChargeView.showDialogView(
                    widget.plugin, widget.keyring, vfeDetail!,
                    doConfirm: doConfirmCharge);
              }
            }),
            getToolbarItemView(
                context, size, 'assets/images/icon-Bind-on.png', bindButton,
                onTap: () async {
              if (isBond) {
                BrnDialogManager.showConfirmDialog(context,
                    title: "Unbind Device",
                    cancel: 'Cancel',
                    confirm: 'Confirm',
                    message: "Do you want to unbind the device of this VFE?",
                    onConfirm: () async {
                  Navigator.of(context).pop();
                  await unbindDevice(context);
                }, onCancel: () {
                  Navigator.of(context).pop();
                });
              } else {
                //bind
                BindDeviceSelector.showDeviceTypesSelector(context, itemId);
              }
            }),
            getToolbarItemView(
                context, size, 'assets/images/icon-Sell-on.png', 'Sell',
                onTap: () {
              Navigator.of(context).pushNamed(VFESellView.route, arguments: {
                'vfeDetail': vfeDetail,
              });
            }),
            getToolbarItemView(
                context, size, 'assets/images/icon-Transfer-on.png', 'Transfer',
                onTap: () {
              Navigator.of(context)
                  .pushNamed(VFETransferView.route, arguments: {
                'vfeDetail': vfeDetail,
              });
            }),
          ],
        );
      }),
    );
  }

  Widget getToolbarItemView(
      BuildContext context, Size size, String icon, String text,
      {VoidCallback? onTap}) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width / 3),
          border: Border.all(color: _outlineBtnColor, width: 0.5),
        ),
        child: BrnIconButton(
            name: text,
            direction: Direction.top,
            padding: 4,
            widgetWidth: size.width,
            widgetHeight: size.height,
            iconWidget: Image.asset(icon),
            style: TextStyle(color: _outlineBtnColor, fontSize: 12),
            onTap: onTap));
  }

  Widget marketToolbarView(TokenBalanceData marketPrice) {
    final decimals = marketPrice.decimals ?? 0;
    final symbol = marketPrice.symbol ?? '';
    final priceTxt = '${Fmt.balance(marketPrice.amount, decimals)} $symbol';
    final user = widget.keyring.current.address ?? '';
    final owner = vfeDetail?.owner ?? '';
    String btnTxt;
    Function(BuildContext) doTapFunc;
    if (user == owner) {
      btnTxt = 'Cancel';
      doTapFunc = confirmCancelOrder;
    } else {
      btnTxt = 'Buy now';
      doTapFunc = confirmTakeOrder;
    }

    return Container(
        height: 88.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2.0,
              spreadRadius: 0.0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 0.h),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current price',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  priceTxt,
                  style: TextStyle(fontSize: 28),
                ),
              ],
            ),
            SizedBox(
                height: 44.h,
                width: 140.w,
                child: BrnSmallMainButton(
                  radius: 22,
                  bgColor: _backgroundColor,
                  textColor: Colors.white,
                  title: btnTxt,
                  fontSize: 20,
                  onTap: () async {
                    await doTapFunc(context);
                  },
                ))
          ],
        ));
  }

  Future<void> unbindDevice(BuildContext context) async {
    BrnLoadingDialog.show(context,
        content: 'Unbinding', barrierDismissible: false);

    final brandId = vfeDetail?.brandId ?? 0;
    final itemId = vfeDetail?.itemId ?? 0;

    final password = await widget.plugin.api.account.getPassword(
      context,
      widget.keyring.current,
    );
    if (password != null) {
      //unbind
      final res =
          await widget.plugin.api.vfe.unbindDevice(brandId, itemId, password);

      if (!mounted) return;
      if (res.success) {
        BrnToast.show('Unbind device successfully', context);
        setState(() {
          vfeDetail!.deviceKey = '';
          widget.plugin.store.vfe
              .updateUserVFE(widget.keyring.current.pubKey, vfeDetail!);
        });
      } else {
        BrnToast.show('Unbind device failed', context);
      }
    }

    if (!mounted) return;
    BrnLoadingDialog.dismiss(context);
  }

  doConfirmLevelUp() async {
    if (vfeDetail == null) {
      BrnToast.show('VFE is not existed', context);
      return;
    }

    BrnLoadingDialog.show(context,
        content: 'Level up...', barrierDismissible: false);

    final password = await widget.plugin.api.account.getPassword(
      context,
      widget.keyring.current,
    );
    final result = await widget.plugin.api.vfe
        .levelUp(vfeDetail!.brandId!, vfeDetail!.itemId!, password);
    final vfeUpdated = await widget.plugin.api.vfe
        .getVFEDetailByID(vfeDetail!.brandId!, vfeDetail!.itemId!);

    if (!mounted) return;
    BrnLoadingDialog.dismiss(context);

    if (!result.success) {
      // update  state
      BrnToast.show(result.error, context);
    } else {
      BrnToast.show('Level up successfully', context);

      if (vfeUpdated != null) {
        updateVFEInfo(vfeUpdated);
      }
    }
  }

  doConfirmCharge(int chargeNum) async {
    if (vfeDetail == null) {
      BrnToast.show('VFE is not existed', context);
      return;
    }

    BrnLoadingDialog.show(context,
        content: 'Charging...', barrierDismissible: false);

    final password = await widget.plugin.api.account.getPassword(
      context,
      widget.keyring.current,
    );
    final result = await widget.plugin.api.vfe.restorePower(
        vfeDetail!.brandId!, vfeDetail!.itemId!, chargeNum, password);
    final vfeUpdated = await widget.plugin.api.vfe
        .getVFEDetailByID(vfeDetail!.brandId!, vfeDetail!.itemId!);

    if (!mounted) return;
    BrnLoadingDialog.dismiss(context);

    if (!result.success) {
      // update  state
      BrnToast.show(result.error, context);
    } else {
      BrnToast.show('Power Charged', context);
      if (vfeUpdated != null) {
        updateVFEInfo(vfeUpdated);
      }
    }
  }

  updateVFEInfo(VFEDetail vfe) {
    setState(() {
      vfe.owner = vfeDetail!.owner;
      vfeDetail = vfe;
      widget.plugin.store.vfe.updateUserVFE(widget.keyring.current.pubKey, vfe);
    });
  }

  confirmCancelOrder(BuildContext context) async {
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

    final result = await widget.plugin.api.vfeOrder
        .removeOrder(orderId!, password);

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
      // update UI state
      setState(() {
        vfeDetail?.owner = widget.keyring.current.address;
        marketPrice = null;
        orderId = null;
      });
    }
  }

  confirmTakeOrder(BuildContext context) async {
    if (orderId == null) {
      BrnToast.show('Order is not existed', context);
      return;
    }
    final orderOwner = vfeDetail?.owner ?? '';
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
      // update UI state
      setState(() {
        vfeDetail?.owner = widget.keyring.current.address;
        marketPrice = null;
        orderId = null;
      });

    }
  }
}
