import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/pages/root.dart';
import 'package:toearnfun_flutter_app/pages/start/start.dart';
import 'package:toearnfun_flutter_app/service/app_service.dart';
import 'package:toearnfun_flutter_app/plugin.dart';

import 'package:toearnfun_flutter_app/store/app_store.dart';

const get_storage_container = 'configuration';
const log_tag = 'ToEarnFun';

class ToEarnFunApp extends StatefulWidget {
  const ToEarnFunApp({Key? key}) : super(key: key);

  @override
  State<ToEarnFunApp> createState() => _ToEarnFunAppState();
}

class _ToEarnFunAppState extends State<ToEarnFunApp> {
  PluginPolket _network = PluginPolket();
  Keyring? _keyring;
  AppStore? _store;
  AppService? _service;

  Future<int> _initApp() async {
    if (_keyring == null) {
      LogUtil.init(tag: log_tag, isDebug: true);
      _keyring = Keyring();
      await _keyring!.init([_network.basic.ss58 ?? 0]);
      final storage = GetStorage(get_storage_container);
      final store = AppStore(storage);
      await store.init();
      final service = AppService(_network, _keyring!, store);
      service.init();

      setState(() {
        _store = store;
        _service = service;
      });
      LogUtil.d('_initApp.setState');
      // service connecting
      await _service!.plugin.beforeStart(_keyring!);
      await _service!.plugin.start(_keyring!);
      await _service!.plugin.updateNetworkState();
    }

    return 1;
  }

  @override
  void initState() {
    super.initState();
    // _initApp();
  }

  Map<String, Widget Function(BuildContext)> _getRoutes() {
    final pluginPages = _service != null
        ? _service!.plugin.getRoutes(_keyring!)
        : {
            RootView.route: (_) =>
                Container(color: Theme.of(context).hoverColor)
          };
    return {
      /// pages of plugin
      ...pluginPages,

      StartView.route: (_) {
        _initApp();
        return StartView();
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    LogUtil.d('app.build');
    final routes = _getRoutes();

    return ScreenUtilInit(
      designSize: Size(390, 844),
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ToEarnFun',
        theme: new ThemeData(
          primaryColor: Colors.white,
        ),
        initialRoute: StartView.route,
        onGenerateRoute: (settings) {
          if (routes[settings.name] != null) {
            return CupertinoPageRoute(
                builder: routes[settings.name]!, settings: settings);
          } else {
            return null;
          }
        },
      ),
    );
  }
}
