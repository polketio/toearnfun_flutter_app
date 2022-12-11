import 'package:flustars/flustars.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
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

  Future<BluetoothDevice?> queryDevice(String deviceKey) async {
    final res = await plugin.sdk.api.service.webView
        ?.evalJavascript('api.query.$module.devices("0x$deviceKey")');
    if (res != null) {
      return BluetoothDevice.fromJson(res);
    } else {
      return null;
    }
  }

  Future<DispatchResult> bindDevice(String pubKey, String signature, int nonce,
      int? itemId, String? password) async {
    final params = [
      '0x$pubKey',
      '0x$signature',
      nonce,
      itemId,
    ];
    return PolketApi.call(
        keyring, plugin.sdk, module, 'bindDevice', params, password);
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

  Future<List<Producer>> getProducerAll() async {
    final List res = await plugin.sdk.api.service.webView
            ?.evalJavascript('vfe.getProducerAll(api)') ??
        [];
    final list = res.map((e) => Producer.fromJson(e)).toList();
    return list;
  }

  Future<DispatchResult> producerRegister(String? password) async {
    final params = [];
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
        onStatusChange: onStatusChange);
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
}
