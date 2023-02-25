
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api.dart';
import 'package:toearnfun_flutter_app/types/buyback_participant.dart';
import 'package:toearnfun_flutter_app/types/buyback_plan.dart';

class PolketApiBuyback {
  PolketApiBuyback(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  final module = 'buyback';

  Future<List<BuyBackPlan>> getBuybackPlans() async {
    final List res = await plugin.sdk.api.service.webView
        ?.evalJavascript('$module.getBuybackPlans(api)') ??
        [];
    final list = res.map((e) => BuybackPlanJson.fromJson(e)).toList();
    return list;
  }

  Future<BuyBackPlan?> getBuybackPlanById(int planId) async {
    final res = await plugin.sdk.api.service.webView
        ?.evalJavascript('api.query.$module.buybackPlans($planId)');
    if (res != null) {
      res['id'] = planId;
      return BuybackPlanJson.fromJson(res);
    } else {
      return null;
    }
  }

  Future<BuybackParticipant?> getParticipantRegistrations(int planId, String address) async {
    final res = await plugin.sdk.api.service.webView
        ?.evalJavascript('api.query.$module.participantRegistrations($planId, "$address")');
    if (res != null) {
      return BuybackParticipant.fromJson(res);
    } else {
      return null;
    }
  }

  Future<DispatchResult> sellerRegister(int planId, String amount, String? password) async {
    final params = [planId, amount];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'sellerRegister', params, password);
  }
}
