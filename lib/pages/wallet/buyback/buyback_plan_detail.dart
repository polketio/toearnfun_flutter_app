import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/wallet/buyback/buyback_plan_item.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/buyback_participant.dart';
import 'package:toearnfun_flutter_app/types/buyback_plan.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class BuybackPlanDetailView extends StatefulWidget {
  const BuybackPlanDetailView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/buyback/buyback_plan_detail';

  @override
  State<BuybackPlanDetailView> createState() => _BuybackPlanDetailViewState();
}

class _BuybackPlanDetailViewState extends State<BuybackPlanDetailView> {
  final _backgroundColor = HexColor('#956DFD');
  final _labelStyle = TextStyle(fontSize: 12, color: HexColor('#8953ED'));
  final _valueStyle = const TextStyle(fontSize: 24, color: Colors.black);
  final _buttonHeight = 50.h;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lockCtrl = TextEditingController();
  Function()? lockFunc;
  Function()? claimFunc;

  BuyBackPlan? plan;
  TokenBalanceData? sellAsset;
  TokenBalanceData? buyAsset;
  BuybackParticipant? participant;
  String balance = '0';
  int sellAssetDecimals = 0;
  int buyAssetDecimals = 0;
  String sellAssetSymbol = 'PNT';
  String buyAssetSymbol = 'PNT';
  String minSell = '0';
  String locked = '0';
  String rewards = '0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      final planId = data['planId'] ?? 0;
      getPlanInfo(planId);
    });
  }

  getPlanInfo(int planId) async {
    plan = await widget.plugin.api.buyback.getBuybackPlanById(planId);
    await getParticipantInfo(planId);
    setState(() {});
  }

  getParticipantInfo(int planId) async {
    final user = widget.keyring.current.address ?? '';
    participant = await widget.plugin.api.buyback
        .getParticipantRegistrations(planId, user);
    locked = participant?.locked ?? '0';
    rewards = participant?.rewards ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    Widget contentView;
    String title = '';
    if (plan != null) {
      sellAsset =
          widget.plugin.store.assets.getTokenByAssetId(plan!.sellAssetId);
      buyAsset = widget.plugin.store.assets.getTokenByAssetId(plan!.buyAssetId);
      balance = sellAsset?.amount ?? '0';
      sellAssetDecimals = sellAsset?.decimals ?? 0;
      buyAssetDecimals = buyAsset?.decimals ?? 0;
      sellAssetSymbol = sellAsset?.symbol ?? 'PNT';
      buyAssetSymbol = buyAsset?.symbol ?? 'PNT';
      minSell = plan?.minSell ?? '0';

      title = '$sellAssetSymbol / $buyAssetSymbol';
      contentView = CustomScrollView(slivers: [
        SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                planInfoView(),
                Expanded(flex: 1, child: participantInfoView()),
              ],
            ))
      ]);
    } else {
      title = 'Plan Info';
      contentView = const BrnPageLoading(
        content: 'Loading...',
      );
    }

    return KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: getAppBarView(title),
            body: SafeArea(child: contentView)));
  }

  PreferredSizeWidget getAppBarView(String title) {
    return AppBar(
      leading: MyBackButton(),
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      centerTitle: true,
      title: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget planInfoView() {
    if (plan != null) {
      return Container(
          color: _backgroundColor,
          height: 260.h,
          child: BuybackPlanItemView(plan!, widget.plugin));
    } else {
      return const Placeholder();
    }
  }

  Widget participantInfoView() {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          boxShadow: [
            BoxShadow(
              color: _backgroundColor,
              blurRadius: 0.0,
              spreadRadius: 0.0,
              offset: Offset(0, -2),
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //balance, lock input view, claim reward view
            balanceView(
                Fmt.balance(balance, sellAssetDecimals), sellAssetSymbol),
            lockInputView(Fmt.balance(minSell, sellAssetDecimals),
                Fmt.balance(balance, sellAssetDecimals), sellAssetSymbol),
            claimRewardView(
                Fmt.balance(locked, sellAssetDecimals),
                sellAssetSymbol,
                Fmt.balance(rewards, buyAssetDecimals),
                buyAssetSymbol)
          ],
        ),
      )
    ]);
  }

  Widget balanceView(String balance, String symbol) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: HexColor('#f3f5fd'),
          borderRadius: BorderRadius.all(Radius.circular(18))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Balance',
            style: TextStyle(color: HexColor('#5db6a7')),
          ),
          Row(
            children: [
              Text(balance),
              Padding(
                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                child: Text(
                  'FUN',
                  style: TextStyle(color: HexColor('#5db6a7')),
                ),
              ),
              Image.asset('assets/images/icon-$symbol.png', scale: 3)
            ],
          )
        ],
      ),
    );
  }

  Widget lockInputView(String minLocked, String balance, String symbol) {
    return Container(
        margin: EdgeInsets.only(top: 30.h),
        child: Column(
          children: [
            //input, button
            TextFormField(
              maxLines: 1,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Minimum lock $minLocked $symbol',
                hintStyle: TextStyle(color: HexColor('c7c7c7')),
                focusedBorder: focusedBorder(),
                enabledBorder: inputBorder(),
                filled: true,
                fillColor: HexColor('fbf7f7'),
                suffixIcon: TextButton(
                    onPressed: () {
                      setState(() {
                        _lockCtrl.text = balance;
                        lockFunc = doLock;
                      });
                    },
                    child: Text(
                      'MAX',
                      style: TextStyle(
                          color: _backgroundColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900),
                    )),
              ),
              controller: _lockCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    lockFunc = doLock;
                  } else {
                    lockFunc = null;
                  }
                });
              },
            ),
            buttonView('Lock $symbol', Colors.green, doTap: lockFunc)
          ],
        ));
  }

  InputBorder inputBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: HexColor('9b9b9b'), width: 1.0));
  }

  InputBorder focusedBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: HexColor('fbf7f7'), width: 1.0));
  }

  Widget claimRewardView(
      String locked, String lockedSymbol, String earned, String earnedSymbol) {
    final earnedDouble = Fmt.balanceDouble(earned, 0);
    if (earnedDouble > 0) {
      claimFunc = doClaim;
    } else {
      claimFunc = null;
    }
    return Container(
        margin: EdgeInsets.only(top: 30.h),
        child: Column(
          children: [
            //reward, button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Your Locked, Your Earn
                Expanded(
                    flex: 1,
                    child: yourInfoItemView('$lockedSymbol Locked', locked,
                        CrossAxisAlignment.start)),
                Container(
                    height: 40.h,
                    child: VerticalDivider(color: HexColor('#c7c7c7'))),
                Expanded(
                    flex: 1,
                    child: yourInfoItemView('$earnedSymbol Earned', earned,
                        CrossAxisAlignment.end)),
              ],
            ),
            // buttonView('Claim $earnedSymbol', _backgroundColor,
            //     doTap: claimFunc)
          ],
        ));
  }

  Widget buttonView(String text, Color color, {Function()? doTap}) {
    Color btnColor;
    if (doTap == null) {
      btnColor = Colors.black26;
    } else {
      btnColor = color;
    }
    return Container(
        margin: EdgeInsets.only(top: 30.h),
        height: _buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: doTap,
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            backgroundColor: MaterialStateProperty.all(btnColor),
            alignment: Alignment.center,
          ),
          child:
              Text(text, style: TextStyle(fontSize: 24, color: Colors.white)),
        ));
  }

  Widget yourInfoItemView(
      String title, String value, CrossAxisAlignment alignment) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: alignment,
      children: [
        Text(title, style: _labelStyle),
        Text(
          value,
          style: _valueStyle,
        ),
      ],
    );
  }

  doLock() {
    if (plan == null) {
      BrnToast.show('Buyback plan is not existed', context);
      return;
    }
    final minLock = Fmt.tokenInt(minSell, 0);
    final lockAmount = Fmt.tokenInt(_lockCtrl.text.trim(), sellAssetDecimals);
    if (lockAmount.compareTo(minLock) < 0) {
      BrnToast.show(
          'Amount must be greater than ${Fmt.balance(minSell, sellAssetDecimals)}',
          context);
      return;
    }

    // final title = 'Lock $sellAssetSymbol';
    // final message = 'After you lock $sellAssetSymbol, you can not withdraw it';
    confirmLock(lockAmount);
  }

  confirmLock(BigInt lockAmount) async {
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
        content: 'Locking...', barrierDismissible: false);

    final result = await widget.plugin.api.buyback
        .sellerRegister(plan!.id, lockAmount.toString(), password);

    if (!result.success) {
      // update  state
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show(result.error, context);
    } else {
      await widget.plugin.loadUserVFEs(widget.keyring.current.pubKey!);
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show('Lock successfully', context);

      _lockCtrl.text = '';
      getPlanInfo(plan!.id);
    }
  }

  doClaim() async {}
}
