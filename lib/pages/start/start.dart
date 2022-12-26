import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:toearnfun_flutter_app/pages/root.dart';

class StartView extends StatefulWidget {
  StartView({Key? key}) : super(key: key);

  static final String route = '/toearnfun/start';

  @override
  _StartViewState createState() => _StartViewState();
}

class _StartViewState extends State<StartView>
    with SingleTickerProviderStateMixin {
  Function? toPage;
  RiveAnimationController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = OneShotAnimation(
      'idle',
      onStop: () {
        // WalletApp.isInitial++;
        if (toPage != null) toPage!();
      },
    );

    toPage = () {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(RootView.route, (route) => false);
    };

    // _showGuide(context, GetStorage(get_storage_container));
  }

  // Future<void> _showGuide(BuildContext context, GetStorage storage) async {
  //   final storeKey = '${show_guide_status_key}_${await Utils.getAppVersion()}';
  //   final showGuideStatus = storage.read(storeKey);
  //   if (showGuideStatus == null) {
  //     toPage = () async {
  //       Navigator.of(context).pushNamedAndRemoveUntil(
  //           GuidePage.route, (route) => false,
  //           arguments: {'storeKey': storeKey, 'storage': storage});
  //     };
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: RiveAnimation.asset(
                'assets/images/toearnfun.riv',
                animations: const ['idle'],
                controllers: [_controller!],
              ))),
    );
  }
}
