import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class HorizontalStepsView extends StatefulWidget {
  const HorizontalStepsView(
      {Key? key,
      required this.steps,
      required this.currentIndex,
      this.textStyle})
      : assert(steps.length < 6),
        super(key: key);

  final List<StepView> steps;
  final int currentIndex;
  final TextStyle? textStyle;

  @override
  State<HorizontalStepsView> createState() => _HorizontalStepsViewState();
}

class _HorizontalStepsViewState extends State<HorizontalStepsView> {
  @override
  Widget build(BuildContext context) {
    List<Widget> wids = [];
    widget.steps.asMap().forEach((index, value) {
      //build step
      wids.add(Expanded(child: buildStep(value, index), flex: 0));
      if (index + 1 < this.widget.steps.length) {
        wids.add(Expanded(child: divider(), flex: 1));
      }
    });

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: wids,
      ),
    );
  }

  Widget buildStep(StepView step, int index) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.currentIndex == index ? step.doingIcon : step.normalIcon,
          Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: SizedBox(
                  height: 24.h,
                  child: Text(step.stepContentText, style: widget.textStyle))),
        ],
      ),
    );
  }

  Widget divider() {
    return Container(
      child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 36.h),
          child: Container(
              height: 8.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.w),
                color: HexColor('#fbf7f7'),
              ))),
    );
  }
}

class StepView {
  const StepView(
      {required this.normalIcon,
      required this.doingIcon,
      required this.stepContentText});

  final String stepContentText;
  final Widget normalIcon;
  final Widget doingIcon;
}
