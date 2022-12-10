import 'package:auto_size_text/auto_size_text.dart';
import 'package:bruno/bruno.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';
import 'package:toearnfun_flutter_app/utils/time.dart';

class JumpRopeTrainingDetailView extends StatefulWidget {
  JumpRopeTrainingDetailView(this.plugin, this.keyring);

  // JumpRopeTrainingData data;

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/training/jumprope_report_detail';

  @override
  State<JumpRopeTrainingDetailView> createState() =>
      _JumpRopeTrainingDetailViewState();
}

class _JumpRopeTrainingDetailViewState extends State<JumpRopeTrainingDetailView>
    with TickerProviderStateMixin {
  final _backgroundColor = HexColor('#956DFD');
  final _roundColor = HexColor('#f9f7f7');

  SkipResultData report = SkipResultData();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Map;
    report = data["trainingReport"] ?? SkipResultData();
    LogUtil.d("report: $report");

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _backgroundColor,
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.only(top: 28.h),
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(flex: 0, child: topView()),
                      Expanded(flex: 1, child: centerView()),
                      Expanded(flex: 0, child: bottomView()),
                      Expanded(flex: 0, child: buttonView(context)),
                    ]))));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(),
      centerTitle: true,
      title:
          const Text('Training Detail', style: TextStyle(color: Colors.white)),
    );
  }

  Widget topView() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          itemView('assets/images/icon-time_big.png', 'Training Time',
              formatDuration(report.jumpRopeDuration)),
          itemView('assets/images/icon-calories.png', 'Fat burning', '90 KCal'),
          itemView('assets/images/icon-bangsheng.png', 'Rope Breaks',
              '${report.interruptions} Time'),
        ],
      ),
    );
  }

  Widget bottomView() {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        itemView('assets/images/icon-pinlv.png', 'Average Speed',
            '${report.averageSpeed} J/M'),
        itemView('assets/images/icon-speed.png', 'Fastest Speed',
            '${report.maxSpeed} J/M'),
        itemView('assets/images/icon-lianxu.png', 'Most Jumps',
            '${report.maxJumpRopeCount} JUMPS'),
      ],
    ));
  }

  Widget centerView() {
    return Container(
        alignment: Alignment.center,
        child: LayoutBuilder(builder: (context, constraints) {
          // LogUtil.d('constraints.maxWidth: ${constraints.maxWidth}');
          // LogUtil.d('constraints.maxHeight: ${constraints.maxHeight}');
          return Stack(children: [
            centerBackgroundView(context, constraints),
            centerForegroundView(context, constraints),
          ]);
        }));
  }

  Widget centerBackgroundView(
      BuildContext context, BoxConstraints constraints) {
    return Container(
        height: constraints.maxWidth * 2 / 3,
        child: Stack(alignment: Alignment.bottomLeft, children: [
          Container(
            height: constraints.maxWidth * 2 / 3,
            width: constraints.maxWidth * 2 / 3,
            decoration: BoxDecoration(
              color: _roundColor,
              shape: BoxShape.circle,
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: constraints.maxWidth * 0.46,
                width: constraints.maxWidth * 0.46,
                decoration: BoxDecoration(
                  color: _roundColor,
                  shape: BoxShape.circle,
                ),
              ))
        ]));
  }

  Widget centerForegroundView(
      BuildContext context, BoxConstraints constraints) {
    return Container(
        height: constraints.maxWidth * 2 / 3,
        child: Stack(alignment: Alignment.bottomLeft, children: [
          Container(
            height: constraints.maxWidth * 2 / 3,
            width: constraints.maxWidth * 2 / 3,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: LayoutBuilder(builder: (context, innerConstraints) {
              return Stack(alignment: Alignment.center, children: [
                Container(
                  height: innerConstraints.maxWidth * 0.7,
                  width: innerConstraints.maxWidth * 0.7,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: totalJumpsView(report.totalJumpRopeCount),
                )
              ]);
            }),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  height: constraints.maxWidth * 0.46,
                  width: constraints.maxWidth * 0.46,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: LayoutBuilder(builder: (context, innerConstraints) {
                    return Stack(alignment: Alignment.center, children: [
                      Container(
                        alignment: Alignment.center,
                        height: innerConstraints.maxWidth * 0.7,
                        width: innerConstraints.maxWidth * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        // child: Image.asset('assets/images/icon-baoxiang.png'),
                        child: earnFUNView(90, 2),
                      )
                    ]);
                  })))
        ]));
  }

  Widget buttonView(BuildContext context) {
    return Container(
        height: 50.h,
        width: double.infinity,
        margin: EdgeInsets.only(top: 44.h),
        child: ElevatedButton(
          onPressed: () async {
            await uploadTrainingReport(context, report);
          },
          child: const Text('Reported', style: TextStyle(fontSize: 24)),
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(_backgroundColor),
            alignment: Alignment.center,
          ),
        ));
  }

  Widget itemView(String img, String title, String value) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(img),
          Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
              child: Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.green))),
          Text(value,
              style: TextStyle(fontSize: 14, color: HexColor('#BFC0D0'))),
        ],
      ),
    );
  }

  Widget totalJumpsView(int number) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Total', style: TextStyle(color: Colors.black, fontSize: 16)),
        Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
            child: Text('$number',
                style: TextStyle(
                  height: 1.0,
                  textBaseline: TextBaseline.ideographic,
                  package: BrnStrings.flutterPackageName,
                  fontWeight: FontWeight.w500,
                  fontSize: 50,
                  fontFamily: 'Bebas',
                ))),
        Text('JUMPS', style: TextStyle(color: Colors.black, fontSize: 12)),
      ],
    );
  }

  Widget earnFUNView(double fun, int energy) {
    return Padding(
        padding: EdgeInsets.only(left: 10.w, right: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //[FUN ENERGY]
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Image.asset('assets/images/icon-energy.png'),
              AutoSizeText('+ $fun',
                  maxLines: 1, style: TextStyle(fontSize: 20), minFontSize: 10),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Image.asset('assets/images/icon-energy.png'),
              AutoSizeText('- $energy',
                  maxLines: 1, style: TextStyle(fontSize: 20), minFontSize: 10),
            ]),
          ],
        ));
  }

  uploadTrainingReport(BuildContext context, SkipResultData report) async {
    BrnLoadingDialog.show(context,
        content: 'Uploading', barrierDismissible: false);
    final signature = report.signature;
    final reportData = report.encodeData();
    final deviceKey = report.deviceKey;
    final password = await widget.plugin.api.account.getPassword(
      context,
      widget.keyring.current,
    );
    final result = await widget.plugin.api.vfe.uploadTrainingReport(
        deviceKey, signature, reportData, password, onStatusChange: (status) {
      LogUtil.d(status);
      // setState(() {
      //   _status = status;
      // });
    });
    if (!mounted) return;
    if (!result.success) {
      //todo: update report state
      BrnToast.show(result.error, context);
    } else {
      BrnToast.show("Upload report successfully", context);
      //todo: save the reward info and update state
    }

    BrnLoadingDialog.dismiss(context);
  }
}
