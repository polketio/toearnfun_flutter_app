import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api_account.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api_assets.dart';
import 'package:toearnfun_flutter_app/plugin.dart';

class PolketApi {
  PolketApi(PluginPolket plugin, Keyring keyring)
      : assets = PolketApiAssets(plugin),
        account = PolketApiAccount(plugin, keyring);

  final PolketApiAssets assets;
  final PolketApiAccount account;
}
