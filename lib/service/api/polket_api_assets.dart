import 'package:flustars/flustars.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/asset_metadata.dart';

class PolketApiAssets {
  PolketApiAssets(this.plugin);

  final PluginPolket plugin;

  final Map _assetBalances = {};
  final assetBalanceChannel = 'assetBalance';
  final module = 'assetsModule';

  Future<List<TokenBalanceData>> getAllAssets() async {
    final List res = await plugin.sdk.api.assets.service.getAssetsAll() ?? [];
    final tokens = res
        .map((e) => TokenBalanceData(
              id: e['id'].toString(),
              name: e['symbol'],
              fullName: e['name'],
              symbol: e['symbol'],
              decimals: int.parse(e['decimals']),
            ))
        .toList();
    return tokens;
  }

  Future<AssetMetadata?> queryMetaData(int classId) async {
    final res = await plugin.sdk.api.service.webView
        ?.evalJavascript('api.query.$module.metadata($classId)');
    if (res != null) {
      return AssetMetadata.fromJson(res);
    } else {
      return null;
    }
  }

  void unsubscribeTokenBalances(String address) async {
    final tokens = await getAllAssets();
    tokens.forEach((e) {
      plugin.sdk.api.unsubscribeMessage('$assetBalanceChannel${e.symbol}');
    });
  }

  Future<void> subscribeTokenBalances(
      String address, Function(List<TokenBalanceData>) callback) async {
    final tokens = await getAllAssets();
    _assetBalances.clear();

    tokens.forEach((e) {
      final channel = '$assetBalanceChannel${e.symbol}';
      plugin.sdk.api.subscribeMessage(
        'api.query.$module.account',
        [e.id, address],
        channel,
        (Map data) {
          data['symbol'] = e.symbol;
          data['name'] = e.name;
          _assetBalances[e.symbol] = data;
          LogUtil.d('asset update: $data');
          // do not callback if we did not receive enough data.
          if (_assetBalances.keys.length < tokens.length) return;

          callback(_assetBalances.values
              .map((t) => TokenBalanceData(
                    name: t['name'],
                    symbol: t['symbol'],
                    amount: t['balance'].toString(),
                    // detailPageRoute: '/assets/token/detail',
                  ))
              .toList());
        },
      );
    });
  }
}
