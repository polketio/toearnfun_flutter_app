import 'package:flukit/flukit.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class ProfileView extends StatefulWidget {
  ProfileView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/profile';

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  KeyPairData? currentAccount;

  final _backgroundColor = HexColor('#956DFD');

  @override
  void initState() {
    super.initState();
    // [check] Has a wallet been created? load assets:show dialog
    if (widget.keyring.allAccounts.length > 0) {
      // show current account
      this.currentAccount = widget.keyring.current;
      LogUtil.d('current address: ${this.currentAccount!.address}');
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
      title: Text('Profile', style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: getAppBarView(),
          body: SafeArea(
              child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverPersistentHeader(
                delegate: SliverHeaderDelegate(
                  maxHeight: 100.h,
                  minHeight: 100.h,
                  child: profileView(context),
                ),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: SliverHeaderDelegate(
                      maxHeight: 20.h,
                      minHeight: 20.h,
                      child: Stack(fit: StackFit.expand, children: [
                        Container(
                            decoration: BoxDecoration(
                          color: _backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: _backgroundColor,
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        )),
                        Container(
                            decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ))
                      ]))),
              settingsListView(),
            ],
          )));
    });
  }

  // show user profile view
  Widget profileView(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 8.h),
        decoration: new BoxDecoration(
          color: _backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //[avatar, name, arrow]
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Image.asset('assets/images/icon-Avatar.png'),
              Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //[name, badge]
                      SizedBox(
                          height: 30.h,
                          child: Text(currentAccount?.name ?? 'Funny Boy',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white))),
                      Row(
                        children: [
                          Image.asset('assets/images/icon-bagde.png'),
                        ],
                      )
                    ],
                  )),
            ]),
            Image.asset('assets/images/icon-jt-white.png'),
          ],
        ));
  }

  // show settings list
  Widget settingsListView() {
    return SliverFixedExtentList(
      itemExtent: 70.h,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          Widget title, trailing;
          TextStyle titleTextStyle =
              TextStyle(fontSize: 16, color: HexColor('#6ebcaf'));
          const trailingTextStyle =
              TextStyle(fontSize: 16, color: Colors.black);
          switch (index) {
            case 0:
              {
                title = Text('Email', style: titleTextStyle);
                trailing = Text('funnyboy@gmail.com', style: trailingTextStyle);
              }
              break;

            case 1:
              {
                title = Text('Height', style: titleTextStyle);
                trailing = Text('170cm', style: trailingTextStyle);
              }
              break;
            case 2:
              {
                title = Text('Weight', style: titleTextStyle);
                trailing = Text('68kg', style: trailingTextStyle);
              }
              break;
            case 3:
              {
                title = Text('Gender', style: titleTextStyle);
                trailing = Text('Boy', style: trailingTextStyle);
              }
              break;
            case 4:
              {
                title = Text('Birthday', style: titleTextStyle);
                trailing = Text('1999-09-09', style: trailingTextStyle);
              }
              break;
            case 5:
              {
                title = Text('Version', style: titleTextStyle);
                trailing = Text('1.0.0', style: trailingTextStyle);
              }
              break;
            default:
              {
                title = Text('Version', style: titleTextStyle);
                trailing = Text('1.0.0', style: trailingTextStyle);
              }
              break;
          }

          return ListTile(
              title: title, trailing: trailing, onTap: () => print(index));
        },
        childCount: 6,
      ),
    );
  }
}
