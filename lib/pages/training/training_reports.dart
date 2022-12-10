import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/pages/training/training_detail.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';
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
  List<SkipResultData> jumpRopeTrainingReportList = [];

  @override
  void initState() {
    super.initState();
    loadJumpRopeTrainingReport();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Scaffold(
          backgroundColor: HexColor('#956DFD'),
          appBar: getAppBarView(),
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
                  await Future<void>.delayed(const Duration(seconds: 2));
                  loadJumpRopeTrainingReport();
                },
              ),
              trainingReportListView(),
            ],
          ))));
    });
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: HexColor('#956DFD'),
      leading: MyBackButton(),
      centerTitle: true,
      title: Text('Training Report', style: TextStyle(color: Colors.white)),
    );
  }

  Widget trainingReportListView() {
    return SliverFixedExtentList(
      itemExtent: 180,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final d = jumpRopeTrainingReportList[index];
          return JumpRopeTrainingReportItem(d);
        },
        childCount: jumpRopeTrainingReportList.length,
      ),
    );
  }

  Future<void> loadJumpRopeTrainingReport() async {

   widget.plugin.store.report.loadTrainingReportList();
    setState(() {
      jumpRopeTrainingReportList = widget.plugin.store.report.userTrainingReportList;
    });
  }
}

class JumpRopeTrainingReportItem extends StatelessWidget {
  JumpRopeTrainingReportItem(this.data);

  SkipResultData data;

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
                                Text(formatTimestamp(timestamp: data.reportTime, date: 'MM/DD hh:mm', toInt: false),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black)),
                                IconText(
                                  'assets/images/icon-dd.png',
                                  'Not Reported',
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
                                                      formatDuration(data.trainingDuration),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    )),
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(children: [
                                                    IconText(
                                                        'assets/images/icon-rl.png',
                                                        '389',
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
              Navigator.of(context).pushNamed(JumpRopeTrainingDetailView.route, arguments: {
                "trainingReport": data,
              });
            }));
  }
}
