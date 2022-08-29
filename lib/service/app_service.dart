import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/service/api_account.dart';
import 'package:toearnfun_flutter_app/store/app_store.dart';

class AppService {
  AppService(this.plugin, this.keyring, this.store);

  // final List<PolkawalletPlugin>? allPlugins;
  final PolkawalletPlugin plugin;
  final Keyring keyring;
  final AppStore store;

  late ApiAccount _account;

  ApiAccount get account => _account;

  void init() {
    _account = ApiAccount(this);
  }
}
