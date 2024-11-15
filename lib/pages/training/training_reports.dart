import 'dart:async';

import 'package:bruno/bruno.dart';
import 'package:flukit/flukit.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:realm/realm.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/simulated_device.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/pages/training/training_detail.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';
import 'package:toearnfun_flutter_app/utils/sport.dart';
import 'package:toearnfun_flutter_app/utils/time.dart';

class JumpRopeTrainingReportsView extends StatefulWidget {
  JumpRopeTrainingReportsView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/training/jumprope_report_list';

  @override
  State<JumpRopeTrainingReportsView> createState() =>
      _JumpRopeTrainingReportsViewState();
}

class _JumpRopeTrainingReportsViewState
    extends State<JumpRopeTrainingReportsView> {
  RealmResults<TrainingReport>? jumpRopeTrainingReportList;
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadJumpRopeTrainingReport();
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor('#956DFD'),
        appBar: getAppBarView(context),
        body: SafeArea(
            child: PullRefreshScope(
                child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPullRefreshIndicator(
              refreshTriggerPullDistance: 100.h,
              refreshIndicatorExtent: 60.h,
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 600));
                // loadJumpRopeTrainingReport();
                loadJumpRopeTrainingReport();
              },
            ),
            trainingReportListView(),
          ],
        ))));
  }

  PreferredSizeWidget getAppBarView(BuildContext context) {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      leading: MyBackButton(),
      centerTitle: true,
      title: Text('Training Report', style: TextStyle(color: Colors.white)),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              generateSimulatedReport(context);
            },
            icon: const Icon(Icons.add_chart_rounded),
            iconSize: 36.w),
      ],
    );
  }

  void generateSimulatedReport(BuildContext context) async {
    final report = SimulatedDeviceConnector().generateRandomReport();
    if (report == null) {
      BrnEnhanceOperationDialog enhanceOperationDialog =
          BrnEnhanceOperationDialog(
        iconType: BrnDialogConstants.iconAlert,
        context: context,
        titleText: "Tips",
        descText: "Connected device is not simulated.",
        mainButtonText: "Got it",
      );
      enhanceOperationDialog.show();
      return;
    }
    loadJumpRopeTrainingReport();
  }

  Widget trainingReportListView() {
    final list = jumpRopeTrainingReportList?.toList() ?? [];
    if (list.isEmpty) {
      return SliverFillViewport(
          viewportFraction: 1.0,
          delegate: SliverChildBuilderDelegate((context, index) {
            return const NoDataView();
          }));
    } else {
      return SliverFixedExtentList(
        itemExtent: 180,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // final d = jumpRopeTrainingReportList[index];
            final d = list[index];
            return JumpRopeTrainingReportItem(d);
          },
          childCount: list.length,
        ),
      );
    }
  }

  Future<void> loadJumpRopeTrainingReport() async {
    jumpRopeTrainingReportList =
        widget.plugin.store.report.loadTrainingReportList();
    subscription ??= jumpRopeTrainingReportList?.changes.listen((event) {
      LogUtil.d('event: ${event.toString()}');
      setState(() {});
    });

    final reportValidityPeriod =
        int.parse(widget.plugin.networkConst['vfe']['reportValidityPeriod']);
    LogUtil.d('reportValidityPeriod: $reportValidityPeriod');
  }
}

class JumpRopeTrainingReportItem extends StatelessWidget {
  JumpRopeTrainingReportItem(this.data);

  // SkipResultData data;
  TrainingReport data;

  @override
  Widget build(BuildContext context) {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final kcal = calCalBurnedForJumpRope(
        data.jumpRopeDuration, data.totalJumpRopeCount, 0);
    return Card(
        elevation: 0,
        margin:
            EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w, bottom: 12.h),
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
        child: GestureDetector(
            child: Padding(
                padding: EdgeInsets.only(left: 12.w, right: 12.w),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 40.h,
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //[reportTime, status]
                                Text(
                                    formatTimestamp(
                                        timestamp: data.reportTime,
                                        date: 'MM/DD hh:mm',
                                        toInt: false),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black)),
                                IconText(
                                  data.reportStatus(now).image,
                                  data.reportStatus(now).display,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.green),
                                ),
                              ])),
                      SizedBox(
                          height: 110.h,
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //[image, report data, arror]
                                Padding(
                                    padding:
                                        EdgeInsets.only(top: 6.h, right: 12.w),
                                    child: Image.asset(
                                        'assets/images/icon-jumprope.png')),
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //[img, total jump count]
                                          Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(children: [
                                                  IconText(
                                                    'assets/images/icon-ts.png',
                                                    '${data.totalJumpRopeCount}',
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        color: Colors.black),
                                                  ),
                                                  Text('Times'),
                                                ]),
                                                Image.asset(
                                                    'assets/images/icon-LeftArrow.png'),
                                              ]),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                //[training time, calorie cost]
                                                Expanded(
                                                    flex: 1,
                                                    child: IconText(
                                                      'assets/images/icon-js.png',
                                                      formatDuration(data
                                                          .trainingDuration),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    )),
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(children: [
                                                    IconText(
                                                        'assets/images/icon-rl.png',
                                                        Fmt.priceFloor(kcal,
                                                            lengthFixed: 1),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black)),
                                                    Text('kcal'),
                                                  ]),
                                                ),
                                              ]),
                                        ])),
                              ]))
                    ])),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(JumpRopeTrainingDetailView.route, arguments: {
                'trainingReport': data,
              });
            }));
  }
}
