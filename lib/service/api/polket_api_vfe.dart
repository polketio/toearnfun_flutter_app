import 'package:flustars/flustars.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/service/api/polket_api.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/producer.dart';
import 'package:toearnfun_flutter_app/types/user.dart';
import 'package:toearnfun_flutter_app/types/vfe_brand.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

class PolketApiVFE {
  PolketApiVFE(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  final module = 'vfe';

  final userStateChannel = 'userState';
  final lastEnergyRecoveryChannel = 'lastEnergyRecovery';

  Future<FitnessDevice?> getDevice(String deviceKey) async {
    final res = await plugin.sdk.api.service.webView
        ?.evalJavascript('api.query.$module.devices("0x$deviceKey")');
    if (res != null) {
      return FitnessDevice.fromJson(res);
    } else {
      return null;
    }
  }

  Future<DispatchResult> bindDevice(String from, String pubKey,
      String signature, int nonce, int? itemId, String? password) async {
    final params = [
      from,
      '0x$pubKey',
      '0x$signature',
      nonce,
      itemId,
    ];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'bindDevice', params, password,
        isUnsigned: true);
  }

  Future<DispatchResult> registerDevice(
      String pubKey, int producerId, int brandId, String? password) async {
    final params = [
      '0x$pubKey',
      producerId,
      brandId,
    ];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'registerDevice', params, password);
  }

  Future<List<VFEBrand>> getVFEBrandsAll() async {
    final List res = await plugin.sdk.api.service.webView
            ?.evalJavascript('vfe.getVFEBrandsAll(api)') ??
        [];
    final list = res.map((e) => VFEBrand.fromJson(e)).toList();
    return list;
  }

  Future<List<VFEDetail>> getVFEDetailsByAddress(
      String address, int brandId) async {
    final List res = await plugin.sdk.api.service.webView?.evalJavascript(
            'vfe.getVFEDetailsByAddress(api, "$address", $brandId)') ??
        [];
    final list = res.map((e) => VFEDetail.fromJson(e)).toList();
    return list;
  }

  Future<VFEDetail?> getVFEDetailByID(
      int brandId, int itemId) async {
    final res = await plugin.sdk.api.service.webView?.evalJavascript(
        'api.query.$module.vfeDetails($brandId, $itemId)');
    if (res != null) {
      return VFEDetail.fromJson(res);
    } else {
      return null;
    }
  }

  Future<List<Producer>> getProducerAll() async {
    final List res = await plugin.sdk.api.service.webView
            ?.evalJavascript('vfe.getProducerAll(api)') ??
        [];
    final list = res.map((e) => Producer.fromJson(e)).toList();
    return list;
  }

  Future<DispatchResult> producerRegister(String who, String? password) async {
    final params = [who];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'producerRegister', params, password);
  }

  Future<DispatchResult> unbindDevice(
      int brandId, int itemId, String? password) async {
    final params = [brandId, itemId];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'unbindDevice', params, password);
  }

  Future<DispatchResult> uploadTrainingReport(
      String deviceKey, String signature, String reportData, String? password,
      {Function(String)? onStatusChange}) async {
    final params = ['0x$deviceKey', '0x$signature', '0x$reportData'];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'uploadTrainingReport', params, password,
        onStatusChange: onStatusChange, isUnsigned: true);
  }

  Future<User> getUserState(String address) async {
    final res = await plugin.sdk.api.service.webView
        ?.evalJavascript('api.query.$module.users("$address")');
    if (res != null) {
      return User.fromJson(res);
    } else {
      return User(owner: address);
    }
  }

  void unsubscribeUserState(String address) async {
    plugin.sdk.api.unsubscribeMessage(userStateChannel);
  }

  Future<void> subscribeUserState(
      String address, Function(User) callback) async {
    plugin.sdk.api.subscribeMessage(
      'api.query.$module.users',
      [address],
      userStateChannel,
      (data) {
        callback(User.fromJson(data));
      },
    );
  }

  Future<DispatchResult> userRestore(String? password) async {
    final params = [];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'userRestore', params, password);
  }

  void unsubscribeLastEnergyRecovery() async {
    plugin.sdk.api.unsubscribeMessage(lastEnergyRecoveryChannel);
  }

  Future<void> subscribeLastEnergyRecovery(Function(int) callback) async {
    plugin.sdk.api.subscribeMessage(
      'api.query.$module.lastEnergyRecovery',
      [],
      lastEnergyRecoveryChannel,
      (data) {
        callback(int.parse(data));
      },
    );
  }

  Future<String> getChargingCosts(
      int brandId, int itemId, int chargeNum) async {
    final cost = await plugin.sdk.api.service.webView?.evalJavascript(
        'vfe.getChargingCosts(api, $brandId, $itemId, $chargeNum)');
    return cost;
  }

  Future<String> getLevelUpCosts(
      String who, int brandId, int itemId) async {
    final cost = await plugin.sdk.api.service.webView
        ?.evalJavascript('vfe.getLevelUpCosts(api, "$who", $brandId, $itemId)');
    return cost;
  }

  Future<TokenBalanceData?> getIncentiveToken() async {
    final res = await plugin.sdk.api.service.webView
        ?.evalJavascript('vfe.getIncentiveToken(api)');
    if (res != null) {
      final token = TokenBalanceData(
        id: res['id'].toString(),
        name: res['name'],
        fullName: res['name'],
        symbol: res['symbol'],
        decimals: int.parse(res['decimals']),
      );
      return token;
    } else {
      return null;
    }
  }

  Future<DispatchResult> restorePower(int brandId, int itemId, int chargeNum, String? password) async {
    final params = [brandId, itemId, chargeNum];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'restorePower', params, password);
  }

  Future<DispatchResult> levelUp(int brandId, int itemId, String? password) async {
    final params = [brandId, itemId];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'levelUp', params, password);
  }

  Future<DispatchResult> increaseAbility(int brandId, int itemId, VFEAbility ability, String? password) async {
    final params = [brandId, itemId, ability];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'increaseAbility', params, password);
  }

  int get reportValidityPeriod {
    if (plugin.networkConst.isNotEmpty) {
      return int.parse(plugin.networkConst[module]['reportValidityPeriod']);
    } else {
      return 0;
    }
  }

  int get energyRecoveryDuration {
    if (plugin.networkConst.isNotEmpty) {
      return int.parse(plugin.networkConst[module]['energyRecoveryDuration']);
    } else {
      return 0;
    }
  }

  int get dailyEarnedResetDuration {
    if (plugin.networkConst.isNotEmpty) {
      return int.parse(plugin.networkConst[module]['dailyEarnedResetDuration']);
    } else {
      return 0;
    }
  }
}
