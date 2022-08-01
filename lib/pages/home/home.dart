import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

// HomeView
class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        VFECard(),
      ],
    );
  }
}

// VFE Card show VFE Image
class VFECard extends StatefulWidget {
  const VFECard({Key? key}) : super(key: key);

  @override
  State<VFECard> createState() => _VFECardState();
}

class _VFECardState extends State<VFECard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(8.w, 0.h, 8.w, 0.h),
          child: Image.asset(
            "assets/images/home_bg.png",
            fit: BoxFit.cover,
          ),
        ),
        Column(children: [
          Padding(
              padding: EdgeInsets.only(
                  left: 0, right: 0, top: 88, bottom: 0)),
          Container(
              alignment: Alignment.center,
              child: SizedBox(
                  height: 200,
                  child: Image.asset("assets/images/vfe_sample.png")))
        ]),
      ]),
    );
  }
}
