import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api_account.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api_assets.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api_buyback.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api_system.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api_vfe.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api_vfe_order.dart';

class PolketApi {
  PolketApi(PluginPolket plugin, Keyring keyring)
      : assets = PolketApiAssets(plugin),
        account = PolketApiAccount(plugin, keyring),
        vfe = PolketApiVFE(plugin, keyring),
        buyback = PolketApiBuyback(plugin, keyring),
        vfeOrder = PolketApiVFEOrder(plugin, keyring),
        system = PolketApiSystem(plugin, keyring);

  final PolketApiAssets assets;
  final PolketApiAccount account;
  final PolketApiVFE vfe;
  final PolketApiSystem system;
  final PolketApiBuyback buyback;
  final PolketApiVFEOrder vfeOrder;

  static Future<DispatchResult> call(
    Keyring keyring,
    WalletSDK sdk,
    String module,
    String method,
    List params,
    String? password, {
    bool isUnsigned = false,
    Function(String)? onStatusChange,
    String? rawParam,
  }) async {
    final sender = TxSenderData(
      keyring.current.address,
      keyring.current.pubKey,
    );
    final txInfo = TxInfoData(module, method, sender, isUnsigned: isUnsigned);
    try {
      final result = await sdk.api.tx.signAndSend(
        txInfo,
        params,
        password ?? '',
        onStatusChange: onStatusChange,
        rawParam: rawParam,
      );
      return DispatchResult.fromJson(result);
    } catch (err) {
      return DispatchResult.fail(err);
    }
  }
}

class DispatchResult {
  String txId = '';
  String blockHash = '';
  String error = '';
  bool success = false;
  List<TxEvent> events = [];

  static DispatchResult fromJson(dynamic json) {
    final data = DispatchResult();
    data.txId = json['hash'] ?? '';
    data.blockHash = json['blockHash'] ?? '';
    List events = json['events'] ?? [];
    data.events = events.map((e) => TxEvent.fromJson(e)).toList();
    data.success = true;
    return data;
  }

  static DispatchResult fail(dynamic error) {
    final data = DispatchResult();
    data.success = false;
    data.error = error.toString();
    return data;
  }
}

class TxEvent {
  String title = '';
  List<dynamic> message = [];

  TxEvent();

  static TxEvent fromJson(Map<String, dynamic> json) {
    TxEvent e = TxEvent();
    e.title = json['title'] ?? '';
    e.message = json['message'] ?? [];
    return e;
  }
}
