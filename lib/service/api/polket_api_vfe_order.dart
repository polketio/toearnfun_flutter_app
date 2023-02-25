import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api.dart';
import 'package:toearnfun_flutter_app/types/buyback_participant.dart';
import 'package:toearnfun_flutter_app/types/buyback_plan.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/types/vfe_order.dart';

class PolketApiVFEOrder {
  PolketApiVFEOrder(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  final module = 'vfeOrder';

  Future<List<Order>> getOrdersAll() async {
    final List res = await plugin.sdk.api.service.webView
            ?.evalJavascript('$module.getOrdersAll(api)') ??
        [];
    final list = res.map((e) => Order.fromJson(e)).toList();
    return list;
  }

  Future<DispatchResult> submitOrder(int assetId, String price, int deadline,
      OrderItem item, String? password) async {
    final params = [
      assetId,
      price,
      deadline,
      [item]
    ];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'submitOrder', params, password);
  }

  Future<DispatchResult> takeOrder(
      int orderId, String orderOwner, String? password) async {
    final params = [orderId, orderOwner];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'takeOrder', params, password);
  }

  Future<DispatchResult> removeOrder(int orderId, String? password) async {
    final params = [orderId];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'removeOrder', params, password);
  }
}
