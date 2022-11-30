import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/pages/root.dart';
import 'package:toearnfun_flutter_app/pages/start/start.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/store/plugin_store.dart';

const get_storage_container = 'configuration';
const log_tag = 'ToEarnFun';

class ToEarnFunApp extends StatefulWidget {
  const ToEarnFunApp({Key? key}) : super(key: key);

  @override
  State<ToEarnFunApp> createState() => _ToEarnFunAppState();
}

class _ToEarnFunAppState extends State<ToEarnFunApp> {

  PluginPolket? _network;
  Keyring? _keyring;

  Future<int> _initApp() async {
    if (_keyring == null) {

      LogUtil.init(tag: log_tag, isDebug: true);

      final store = PluginStore();
      await store.init();

      final network = PluginPolket(store);
      _keyring = Keyring();
      await _keyring!.init([network.basic.ss58 ?? 0]);
      setState(() {
        _network = network;
      });
      LogUtil.d('_initApp.setState');
      // service connecting
      await _network?.beforeStart(_keyring!);
      await _network?.start(_keyring!);
      await _network?.updateNetworkState();

      BluetoothDeviceConnector.init(network.store!.devices);
    }

    return 1;
  }

  @override
  void initState() {
    super.initState();
    // _initApp();
  }

  Map<String, Widget Function(BuildContext)> _getRoutes() {
    final pluginPages = _network != null
        ? _network!.getRoutes(_keyring!)
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
