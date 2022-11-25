import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_complete.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_scanner.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_tips.dart';
import 'package:toearnfun_flutter_app/pages/device/device_connect.dart';
import 'package:toearnfun_flutter_app/pages/profile/profile.dart';
import 'package:toearnfun_flutter_app/pages/root.dart';
import 'package:toearnfun_flutter_app/pages/training/training_detail.dart';
import 'package:toearnfun_flutter_app/pages/training/training_reports.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_one.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_three.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_two.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/welcome.dart';
import 'package:toearnfun_flutter_app/pages/wallet/wallet.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api.dart';
import 'package:toearnfun_flutter_app/store/plugin_store.dart';

class PluginPolket extends PolkawalletPlugin {
  // store cache
  PluginStore? _store;

  PluginStore? get store => _store;

  //polket api
  late PolketApi _api;

  PolketApi get api => _api;

  // check node is connected?
  bool _connected = false;

  bool get connected => _connected;

  @override
  final basic = PluginBasicData(
    name: 'Polket',
    ss58: 42,
    primaryColor: Colors.grey,
    icon: Image.asset('assets/images/Coin_PNT.png'),
    iconDisabled: Image.asset('assets/images/Coin_PNT.png'),
    jsCodeVersion: 1,
  );

  @override
  List<NetworkParams> get nodeList {
    return [
      {
        'name': 'Polket Testnet',
        'ss58': 42,
        'endpoint': 'wss://testnet-node.polket.io',
      },
    ].map((e) => NetworkParams.fromJson(e)).toList();
  }

  @override
  Map<String, Widget> get tokenIcons => {
        'KSM': Image.asset('assets/images/icon-KSM.png'),
        'PNT': Image.asset('assets/images/icon-PNT.png'),
        'FUN': Image.asset('assets/images/icon-FUN.png'),
      };

  @override
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) => [];

  @override
  Future<String>? loadJSCode() =>
      rootBundle.loadString('js_service/dist/main.js');

  // @override
  // Future<String>? loadJSCode() => null;

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    LogUtil.d('plugin.getRoutes');
    return {
      RootView.route: (_) => RootView(this, keyring),
      WalletView.route: (_) => WalletView(this, keyring),
      JumpRopeTrainingReportsView.route: (_) => JumpRopeTrainingReportsView(this, keyring),
      NewWalletWelcomeView.route: (_) => NewWalletWelcomeView(this, keyring),
      NewWalletStepOne.route: (_) => NewWalletStepOne(this, keyring),
      NewWalletStepTwo.route: (_) => NewWalletStepTwo(this, keyring),
      NewWalletStepThree.route: (_) => NewWalletStepThree(this, keyring),
      DeviceConnectView.route: (_) => DeviceConnectView(this, keyring),
      JumpRopeTrainingDetailView.route: (_) => JumpRopeTrainingDetailView(this, keyring),
      ProfileView.route: (_) => ProfileView(this, keyring),
      BindDeviceTips.route: (_) => BindDeviceTips(this, keyring),
      BindDeviceScanner.route: (_) => BindDeviceScanner(this, keyring),
      BindDeviceComplete.route: (_) => BindDeviceComplete(this, keyring),
    };
  }

  void _loadCacheData(KeyPairData acc) {
    balances.setTokens([]);
    balances.setExtraTokens([]);

    _store?.assets.loadCache(acc.pubKey);
  }

  Future<void> _subscribeTokenBalances(String address) async {
    _api.assets.subscribeTokenBalances(address, (data) {
      balances.setTokens(data);
      _store?.assets.setTokenBalanceMap(data);
    });
  }

  @override
  Future<void> onWillStart(Keyring keyring) async {
    _api = PolketApi(this, keyring);

    _store = PluginStore();
    await _store!.init();
    _loadCacheData(keyring.current);
    LogUtil.d('plugin.onWillStart');
  }

  @override
  Future<void> onStarted(Keyring keyring) async {
    _connected = true;

    if (keyring.current.address != null) {
      _subscribeTokenBalances(keyring.current.address!);
    }
    LogUtil.d('plugin.onStarted');
  }

  @override
  Future<void> onAccountChanged(KeyPairData acc) async {
    _loadCacheData(acc);

    if (_connected && acc.address != null) {
      _api.assets.unsubscribeTokenBalances(acc.address!);
      _subscribeTokenBalances(acc.address!);
    }
  }
}
