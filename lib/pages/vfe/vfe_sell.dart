import 'dart:ui';

import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_card.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/types/vfe_order.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class VFESellView extends StatefulWidget {
  VFESellView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/vfe/vfe_sell';

  @override
  State<VFESellView> createState() => _VFESellViewState();
}

class _VFESellViewState extends State<VFESellView> {
  final _backgroundColor = HexColor('#956DFD');
  final _buttonHeight = 50.h;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = TextEditingController();
  bool canConfirm = false;

  VFEDetail? vfeDetail;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = ModalRoute
          .of(context)
          ?.settings
          .arguments as Map;
      setState(() {
        vfeDetail = data['vfeDetail'];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentView;
    if (vfeDetail != null) {
      contentView = Container(
          alignment: Alignment.center,
          child: CustomScrollView(slivers: [
            SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      VFECardView(vfeDetail!),
                      Expanded(flex: 1, child: interactView()),
                    ]))
          ]));
    } else {
      contentView = const BrnPageLoading(
        content: 'Loading...',
      );
    }
    return KeyboardDismissOnTap(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: _backgroundColor,
            appBar: getAppBarView(),
            body: SafeArea(child: contentView)));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(onBack: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        await Future<void>.delayed(const Duration(milliseconds: 200), () {
          Navigator.of(context).pop();
        });
      }),
      centerTitle: true,
      title: const Text('Sell VFE', style: TextStyle(color: Colors.white)),
    );
  }

  Widget vfeCardView(BuildContext context) {
    String vfeImage = 'assets/images/vfe-card.png';
    final itemId = '#${vfeDetail?.itemId.toString().padLeft(4, '0')}';
    return Stack(children: <Widget>[
      // background
      Container(
        margin: EdgeInsets.fromLTRB(8.w, 0.h, 8.w, 0.h),
        child: Image.asset(
          'assets/images/home_bg.png',
          fit: BoxFit.cover,
        ),
      ),
      //col: [vfe-img, state-row]
      Column(children: [
        Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 0),
            child: Image.asset(vfeImage)),
        Padding(
            padding: EdgeInsets.only(top: 16.h, left: 24.w, right: 24.w),
            child: Row(
              //row: [ID, status, power]
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text('VFE ID',
                            style: TextStyle(
                                color: Colors.greenAccent, fontSize: 12)),
                        SizedBox(
                            height: 24.h,
                            child: Text(itemId,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16))),
                      ],
                    )),
                Expanded(
                    flex: 1,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('LEVEL',
                            style: TextStyle(
                                color: Colors.greenAccent, fontSize: 12)),
                        SizedBox(
                            height: 24.h,
                            child: Text('Lv ${vfeDetail?.level}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)))
                      ],
                    )),
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                            width: 80.w,
                            child: const Text('RARITY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.greenAccent, fontSize: 12))),
                        SizedBox(
                            width: 80.w,
                            height: 24.h,
                            child: Text(vfeDetail?.rarity.name ?? "",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16))),
                      ],
                    ))
              ],
            ))
      ]),
    ]);
  }

  Widget interactView() {
    return Container(
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 0),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: inputsView()),
              buttonView(context),
            ]));
  }

  Widget inputsView() {
    return Form(
        key: _formKey,
        child: Container(
            alignment: Alignment.centerLeft,
            child: Column(children: [
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 0.h, bottom: 16.h),
                  width: double.infinity,
                  child: const Text('Set a price',
                      style: TextStyle(color: Colors.black, fontSize: 18))),
              TextFormField(
                maxLines: 1,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Amount',
                  hintStyle: TextStyle(color: HexColor('c7c7c7')),
                  focusedBorder: focusedBorder(),
                  enabledBorder: inputBorder(),
                  filled: true,
                  fillColor: HexColor('fbf7f7'),
                  suffixIcon: Image.asset(
                      'assets/images/icon-PNT.png', scale: 2.5),
                ),
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                onChanged: (value) {
                  setState(() {
                    canConfirm = value.isNotEmpty;
                  });
                },
              ),
            ])));
  }

  InputBorder inputBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: HexColor('9b9b9b'), width: 1.0));
  }

  InputBorder focusedBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _backgroundColor, width: 1.0));
  }

  Widget buttonView(BuildContext context) {
    Function()? onPressed;
    Color btnColor;
    if (canConfirm) {
      final amount = _amountCtrl.text.trim();
      final message = 'VFE will be listed on the market with price: $amount PNT.';
      onPressed = () {
        final price = Fmt.tokenInt(_amountCtrl.text.trim(), 12);
        if (price.compareTo(BigInt.zero) < 0) {
          BrnToast.show(
              'Amount must be greater than 0',
              context);
          return;
        }
        confirmMakeOrder(context, price);

      };
      btnColor = _backgroundColor;
    } else {
      onPressed = null;
      btnColor = Colors.black26;
    }

    return Container(
        margin: EdgeInsets.only(bottom: 28.h),
        height: _buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            backgroundColor: MaterialStateProperty.all(btnColor),
            alignment: Alignment.center,
          ),
          child: const Text('Make Order',
              style: TextStyle(fontSize: 24, color: Colors.white)),
        ));
  }

  confirmMakeOrder(BuildContext context, BigInt price) async {
    if (vfeDetail == null) {
      BrnToast.show('VFE is not existed', context);
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

    final current = widget.plugin.store.system.currentBlockNumber;

    if (!mounted) return;
    BrnLoadingDialog.show(context,
        content: 'Submitting...', barrierDismissible: false);

    final item = OrderItem(vfeDetail!.brandId!, vfeDetail!.itemId!);
    final result = await widget.plugin.api.vfeOrder.submitOrder(
        0, price.toString(), current + 100, item, password);

    if (!result.success) {
      // update  state
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show(result.error, context);
    } else {
      await widget.plugin.loadUserVFEs(widget.keyring.current.pubKey!);
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show('Make order successfully', context);
      // pop to root
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
