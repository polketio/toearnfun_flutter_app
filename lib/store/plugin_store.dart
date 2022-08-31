import 'package:get_storage/get_storage.dart';
import 'package:toearnfun_flutter_app/store/account.dart';
import 'package:toearnfun_flutter_app/store/assets.dart';

class PluginStore {
  static const polket_plugin_cache_key = 'plugin_polket';

  final GetStorage _storage = GetStorage(polket_plugin_cache_key);

  GetStorage get storage => _storage;

  late AssetsStore assets;
  late AccountStore account;

  Future<void> init() async {
    await GetStorage.init(polket_plugin_cache_key);
    assets = AssetsStore(_storage);
    account = AccountStore();
  }
}
