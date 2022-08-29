import 'package:toearnfun_flutter_app/service/api/polket_api_assets.dart';
import 'package:toearnfun_flutter_app/plugin.dart';

class PolketApi {
  PolketApi(PluginPolket plugin) : assets = PolketApiAssets(plugin);

  final PolketApiAssets assets;
}
