import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:toearnfun_flutter_app/common/consts.dart';
import 'package:toearnfun_flutter_app/pages/root.dart';
import 'package:toearnfun_flutter_app/pages/start/start.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/welcome.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/service/webViewRunner.dart';
import 'package:toearnfun_flutter_app/store/plugin_store.dart';

const get_storage_container = 'configuration';
const log_tag = 'ToEarnFun';

class ToEarnFunApp extends StatefulWidget {
  ToEarnFunApp(BuildTargets buildTarget) {
    ToEarnFunApp.buildTarget = buildTarget;
  }

  static BuildTargets buildTarget = BuildTargets.apk;

  @override
  State<ToEarnFunApp> createState() => _ToEarnFunAppState();
}

class _ToEarnFunAppState extends State<ToEarnFunApp> {
  PluginPolket? _network;
  Keyring? _keyring;

  Future<int> _initApp(BuildContext context) async {
    if (_keyring == null) {
      LogUtil.init(tag: log_tag, isDebug: true);

      final store = PluginStore();
      await store.init();
      JumpRopeDeviceConnector.init(store);

      final network = PluginPolket(store);
      _keyring = Keyring();
      await _keyring!.init([network.basic.ss58!]);
      setState(() {
        _network = network;
      });
      // LogUtil.d('_initApp.setState');
      // service connecting
      await _network?.beforeStart(_keyring!, webView: WebViewRunnerOverrider());
      await _network?.start(_keyring!);
      await _network?.updateNetworkState();
    }

    final accountCreated = _network?.store?.account?.accountCreated ?? false;
    // final accounts = accountCreated ? 1:0;
    final accounts = _keyring?.allAccounts.length ?? 0;
    return accounts;
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
        _initApp(context);
        return StartView();
      },

      RootView.route: (_) => Observer(builder: (BuildContext context) {
            final accountCreated =
                _network?.store?.account?.accountCreated ?? false;
            return FutureBuilder<int>(
              future: _initApp(context),
              builder: (_, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData && _network != null) {
                  return snapshot.data! > 0
                      ? RootView(_network!, _keyring!)
                      : NewWalletWelcomeView(_network!, _keyring!);
                } else {
                  return Container(color: Theme.of(context).hoverColor);
                }
              },
            );
          }),
    };
  }

  @override
  Widget build(BuildContext context) {

    // LogUtil.d('app.build');
    final routes = _getRoutes();
    // var baseTheme = ThemeData(brightness: Brightness.light);
    return ScreenUtilInit(
      designSize: Size(390, 844),
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ToEarnFun',
        theme: ThemeData(
          primaryColor: Colors.white,
          // textTheme: GoogleFonts.secularOneTextTheme(baseTheme.textTheme),
          // textTheme: GoogleFonts.ibmPlexSansTextTheme(baseTheme.textTheme),
        ),
        localizationsDelegates: const [
          AppLocalizationsDelegate(Locale('en', '')),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('zh', ''),
        ],
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
