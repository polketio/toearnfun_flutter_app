import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/components/v3/addressIcon.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/pages/wallet/account/change_name.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class AccountManageView extends StatefulWidget {
  AccountManageView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/wallet/account';

  @override
  State<AccountManageView> createState() => _AccountManageViewState();
}

class _AccountManageViewState extends State<AccountManageView> {
  KeyPairData? currentAccount;
  String? accountName;
  final _backgroundColor = HexColor('#956DFD');

  @override
  void initState() {
    super.initState();
    // [check] Has a wallet been created? load assets:show dialog
    if (widget.keyring.allAccounts.length > 0) {
      // show current account
      currentAccount = widget.keyring.current;
      accountName = currentAccount?.name;
      // LogUtil.d('current address: ${this.currentAccount!.address}');
    }
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(),
      centerTitle: true,
      title: Text('Account', style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: getAppBarView(),
        body: SafeArea(
            child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverStickyHeader(
              header: accountView(context),
              sticky: true,
              sliver: settingsListView(context),
            ),
          ],
        )));
  }

  // show wallet account view
  Widget accountView(BuildContext context) {
    return Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: _backgroundColor,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //[avatar, name, arrow]
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AddressIcon(currentAccount?.address ?? '',
                              svg: currentAccount?.icon ?? '', size: 60.w),
                          Padding(
                              padding: EdgeInsets.only(left: 12.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //[name, badge]
                                  SizedBox(
                                      height: 30.h,
                                      child: Text(accountName ?? 'Anonymous',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white))),
                                  SizedBox(
                                      height: 30.h,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                Fmt.address(
                                                    currentAccount?.address),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white
                                                        .withOpacity(0.6))),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.w)),
                                            Icon(
                                              Icons.qr_code,
                                              color:
                                                  Colors.white.withOpacity(0.6),
                                            ),
                                          ])),
                                ],
                              )),
                        ]),
                  ],
                ),
              ),
              Container(
                height: 20.h,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              )
            ]));
  }

  // show settings list
  Widget settingsListView(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: 70.h,
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          Widget title;
          TextStyle titleTextStyle =
              TextStyle(fontSize: 16, color: Colors.black);
          IconData icon;
          Function()? onTap;
          switch (index) {
            case 0:
              {
                title = Text('Change Account Name', style: titleTextStyle);
                icon = Icons.person;
                onTap = () async {
                  final value =
                      await Navigator.of(ctx).pushNamed(ChangeNameView.route);
                  if (value != null) {
                    setState(() {
                      accountName = value! as String;
                    });
                  }
                };
              }
              break;

            case 1:
              {
                title = Text('Reset Password', style: titleTextStyle);
                icon = Icons.password;
              }
              break;
            case 2:
              {
                title = Text('Export Mnemonic Phrase', style: titleTextStyle);
                icon = Icons.key;
              }
              break;

            default:
              {
                title = Text('', style: titleTextStyle);
                icon = Icons.person;
              }
              break;
          }

          return ListTile(
              leading: Icon(
                icon,
                color: _backgroundColor,
                size: 30.w,
              ),
              title: title,
              trailing: Image.asset('assets/images/icon-LeftArrow.png'),
              onTap: onTap);
        },
        childCount: 3,
      ),
    );
  }
}
