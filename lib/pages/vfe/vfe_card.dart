import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

class VFECardView extends StatelessWidget {
  VFECardView(this.vfeDetail);

  VFEDetail vfeDetail;

  @override
  Widget build(BuildContext context) {
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
}
