import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
import 'package:toearnfun_flutter_app/pages/vfe/vfe_add_point.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_detail.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_sell.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_transfer.dart';
import 'package:toearnfun_flutter_app/pages/wallet/account/account_manage.dart';
import 'package:toearnfun_flutter_app/pages/wallet/account/change_name.dart';
import 'package:toearnfun_flutter_app/pages/wallet/buyback/buyback_plan_detail.dart';
import 'package:toearnfun_flutter_app/pages/wallet/buyback/buyback_plans.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_one.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_three.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/step_two.dart';
import 'package:toearnfun_flutter_app/pages/wallet/create/welcome.dart';
import 'package:toearnfun_flutter_app/pages/wallet/import/mnemonic.dart';
import 'package:toearnfun_flutter_app/pages/wallet/wallet.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api.dart';
import 'package:toearnfun_flutter_app/store/plugin_store.dart';

class PluginPolket extends PolkawalletPlugin {
  PluginPolket(this.store);

  // store cache
  PluginStore store;

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
        // 'endpoint': 'ws://192.168.31.141:9944',
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
      // RootView.route: (_) => RootView(this, keyring),
      WalletView.route: (_) => WalletView(this, keyring),
      JumpRopeTrainingReportsView.route: (_) =>
          JumpRopeTrainingReportsView(this, keyring),
      NewWalletWelcomeView.route: (_) => NewWalletWelcomeView(this, keyring),
      NewWalletStepOne.route: (_) => NewWalletStepOne(this, keyring),
      NewWalletStepTwo.route: (_) => NewWalletStepTwo(this, keyring),
      NewWalletStepThree.route: (_) => NewWalletStepThree(this, keyring),
      DeviceConnectView.route: (_) => DeviceConnectView(this, keyring),
      JumpRopeTrainingDetailView.route: (_) =>
          JumpRopeTrainingDetailView(this, keyring),
      ProfileView.route: (_) => ProfileView(this, keyring),
      BindDeviceTips.route: (_) => BindDeviceTips(this, keyring),
      BindDeviceScanner.route: (_) => BindDeviceScanner(this, keyring),
      BindDeviceComplete.route: (_) => BindDeviceComplete(this, keyring),
      VFEDetailView.route: (_) => VFEDetailView(this, keyring),
      MnemonicRestoreWallet.route: (_) => MnemonicRestoreWallet(this, keyring),
      VFEAddPointView.route: (_) => VFEAddPointView(this, keyring),
      VFETransferView.route: (_) => VFETransferView(this, keyring),
      BuybackPlansView.route: (_) => BuybackPlansView(this, keyring),
      BuybackPlanDetailView.route: (_) => BuybackPlanDetailView(this, keyring),
      AccountManageView.route: (_) => AccountManageView(this, keyring),
      ChangeNameView.route: (_) => ChangeNameView(this, keyring),
      VFESellView.route: (_) => VFESellView(this, keyring),
    };
  }

  void _loadCacheData(KeyPairData acc) {
    balances.setTokens([]);
    balances.setExtraTokens([]);

    store.assets.loadCache(acc.pubKey);
    store.vfe.loadCurrentVFE(acc.pubKey);
    store.vfe.loadUserState();
  }

  Future<void> loadUserVFEs(String user) async {
    final brands = await _api.vfe.getVFEBrandsAll();
    if (brands.isNotEmpty) {
      store.vfe.allVFEBrands.addAll(brands);
      for (var b in brands) {
        final details =
            await _api.vfe.getVFEDetailsByAddress(user, b.brandId ?? 0);
        for (var d in details) {
          d.setBrandInfo(b);
        }
        await store.vfe.addUserVFEList(user, details);
      }
    }
  }

  Future<void> loadIncentiveToken() async {
    final token = await _api.vfe.getIncentiveToken();
    store.vfe.incentiveToken = token;
  }

  Future<void> _subscribeTokenBalances(String address) async {
    _api.assets.subscribeTokenBalances(address, (data) {
      balances.setTokens(data);
      store.assets.setTokenBalanceMap(data);
    });
  }

  Future<void> _subscribeUserState(String address) async {
    _api.vfe.subscribeUserState(address, (data) {
      store.vfe.updateUserState(data);
    });
  }

  Future<void> _subscribeLastEnergyRecovery() async {
    _api.vfe.subscribeLastEnergyRecovery((data) async {
      store.vfe.updateLastEnergyRecovery(data);
      //update user status
      String? password = await store.account
          .getUserWalletPassword(_api.vfe.keyring.current.pubKey!);
      _api.vfe.userRestore(password);
    });
  }

  Future<void> _subscribeBlockNumber() async {
    _api.system.subscribeBlockNumber((data) {
      store.system.updateCurrentBlockNumber(data);
    });
  }

  @override
  Future<void> onWillStart(Keyring keyring) async {
    _api = PolketApi(this, keyring);

    _loadCacheData(keyring.current);
    LogUtil.d('plugin.onWillStart');
  }

  @override
  Future<void> onStarted(Keyring keyring) async {
    _connected = true;

    if (keyring.current.address != null) {
      // subscribe assets balance
      _subscribeTokenBalances(keyring.current.address!);
      // subscribe user state
      _subscribeUserState(keyring.current.address!);
      // subscribe last energy recovery
      _subscribeLastEnergyRecovery();
      // subscribe new block number
      _subscribeBlockNumber();
      // load incentive token
      loadIncentiveToken();
      // load user vfe
      loadUserVFEs(keyring.current.pubKey!);

      String? password =
          await store.account.getUserWalletPassword(keyring.current.pubKey!);
      _api.vfe.userRestore(password);
    }
    LogUtil.d('plugin.onStarted');
  }

  @override
  Future<void> onAccountChanged(KeyPairData acc) async {
    _loadCacheData(acc);

    if (_connected && acc.address != null) {
      _api.assets.unsubscribeTokenBalances(acc.address!);
      _api.vfe.unsubscribeUserState(acc.address!);
      _api.vfe.unsubscribeLastEnergyRecovery();
      _api.system.unsubscribeBlockNumber();

      _subscribeTokenBalances(acc.address!);
      _subscribeUserState(acc.address!);
      _subscribeLastEnergyRecovery();
      _subscribeBlockNumber();

      String? password = await store.account.getUserWalletPassword(acc.pubKey!);
      _api.vfe.userRestore(password);
    }
  }
}
