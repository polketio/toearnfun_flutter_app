import 'package:flustars/flustars.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/asset_metadata.dart';

class PolketApiAssets {
  PolketApiAssets(this.plugin);

  final PluginPolket plugin;

  final Map<String, TokenBalanceData> _assetBalances = {};
  final assetBalanceChannel = 'assetBalance';
  final module = 'assets';

  Future<List<TokenBalanceData>> getAllAssets() async {
    final List res = await plugin.sdk.api.assets.service.getAssetsAll() ?? [];
    final tokens = res
        .map((e) => TokenBalanceData(
              id: e['id'].toString(),
              name: e['name'],
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

    for (var e in tokens) {
      if (e.symbol == null) {
        continue;
      }
      _assetBalances[e.symbol!] = e;
      final channel = '$assetBalanceChannel${e.symbol}';
      plugin.sdk.api.subscribeMessage(
        'api.query.$module.account',
        [e.id, address],
        channel,
        (data) {
          final symbol = e.symbol!;
          final balance = data != null ? data['balance'].toString() : '0';
          var ab = _assetBalances[symbol];
          if (ab == null) {
            return;
          }
          ab.amount = balance;
          _assetBalances[symbol] = ab;
          // LogUtil.d('asset update: $ab');
          // do not callback if we did not receive enough data.
          if (_assetBalances.keys.length < tokens.length) return;

          callback(_assetBalances.values.toList());
        },
      );
    }
  }
}
