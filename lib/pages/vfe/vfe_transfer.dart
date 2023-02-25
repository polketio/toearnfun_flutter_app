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
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class VFETransferView extends StatefulWidget {
  VFETransferView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/vfe/vfe_transfer';

  @override
  State<VFETransferView> createState() => _VFETransferViewState();
}

class _VFETransferViewState extends State<VFETransferView> {
  final _backgroundColor = HexColor('#956DFD');
  final _buttonHeight = 50.h;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientCtrl = TextEditingController();
  bool canConfirm = false;

  VFEDetail? vfeDetail;
  late FlutterScankit scanKit;

  final _permissions = const [
    Permissions.READ_EXTERNAL_STORAGE,
    Permissions.CAMERA
  ];

  final _permissionGroup = const [
    PermissionGroup.Camera,
    PermissionGroup.Photos
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      setState(() {
        vfeDetail = data['vfeDetail'];
      });
    });

    scanKit = FlutterScankit();
    scanKit.addResultListen((val) {
      debugPrint("scanning result:$val");
      setState(() {
        // recipient = val;
        _recipientCtrl.text = val;
        canConfirm = true;
      });
    });

    FlutterEasyPermission().addPermissionCallback(
        onGranted: (requestCode, perms, perm) {
          startScan();
        },
        onDenied: (requestCode, perms, perm, isPermanent) {});
  }

  @override
  void dispose() {
    scanKit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: _backgroundColor,
            appBar: getAppBarView(),
            body: SafeArea(
                child: Container(
                    alignment: Alignment.center,
                    child: CustomScrollView(slivers: [
                      SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                vfeCardView(context),
                                Expanded(flex: 1, child: contentView()),
                              ]))
                    ])))));
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
      title: const Text('Send VFE', style: TextStyle(color: Colors.white)),
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

  Widget contentView() {
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
                  child: const Text('Recipient',
                      style: TextStyle(color: Colors.black, fontSize: 18))),
              TextFormField(
                maxLines: 1,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Address of receiving VFE',
                  hintStyle: TextStyle(color: HexColor('c7c7c7')),
                  focusedBorder: focusedBorder(),
                  enabledBorder: inputBorder(),
                  filled: true,
                  fillColor: HexColor('fbf7f7'),
                  suffixIcon: IconButton(
                      onPressed: () async {
                        if (!await FlutterEasyPermission.has(
                            perms: _permissions,
                            permsGroup: _permissionGroup)) {
                          FlutterEasyPermission.request(
                              perms: _permissions,
                              permsGroup: _permissionGroup);
                        } else {
                          startScan();
                        }
                      },
                      icon: Icon(Icons.qr_code_scanner)),
                ),
                controller: _recipientCtrl,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.black),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                validator: (v) {
                  return (v?.trim().isNotEmpty ?? false)
                      ? null
                      : 'Recipient is empty';
                },
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
      onPressed = () {
        confirmTransferVFE(context);
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
          child: const Text('Send',
              style: TextStyle(fontSize: 24, color: Colors.white)),
        ));
  }

  Future<void> startScan() async {
    try {
      await scanKit.startScan(scanTypes: [ScanTypes.ALL]);
    } on PlatformException {}
  }

  confirmTransferVFE(BuildContext context) async {
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

    if (!mounted) return;
    BrnLoadingDialog.show(context,
        content: 'Transferring...', barrierDismissible: false);

    final result = await widget.plugin.api.vfe.transfer(vfeDetail!.brandId!,
        vfeDetail!.itemId!, _recipientCtrl.text.trim(), password);

    if (!result.success) {
      // update  state
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show(result.error, context);
    } else {
      await widget.plugin.loadUserVFEs(widget.keyring.current.pubKey!);
      if (!mounted) return;
      BrnLoadingDialog.dismiss(context);
      BrnToast.show('Transfer successfully', context);
      // pop to root
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
