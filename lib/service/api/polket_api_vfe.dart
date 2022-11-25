import 'package:flustars/flustars.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

class PolketApiVFE {
  PolketApiVFE(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  final module = 'vfe';

  Future<BluetoothDevice?> queryDevice(String deviceKey) async {
    final res = await plugin.sdk.api.service.webView
        ?.evalJavascript('api.query.$module.devices("0x$deviceKey")');
    if (res != null) {
      return BluetoothDevice.fromJson(res);
    } else {
      return null;
    }
  }

  Future<bool> bindDevice(String pubkey, String signature, int nonce,
      int? itemId, String password) async {
    final sender = TxSenderData(
      keyring.current.address,
      keyring.current.pubKey,
    );
    final txInfo = TxInfoData(module, "bindDevice", sender);
    try {
      final hash = await plugin.sdk.api.tx.signAndSend(
        txInfo,
        [
          // puk
          "0x$pubkey",
          // signature
          "0x$signature",
          nonce,
          null,
        ],
        password,
        onStatusChange: (status) {
          LogUtil.d(status);
        },
      );
      LogUtil.d('sendTx txid: ${hash.toString()}');
    } catch (err) {
      LogUtil.d('sendTx failed: ${err.toString()}');
      return false;
    }

    return true;
  }

  Future<String> registerDevice(
      String pubkey, int producerId, int brandId, String password) async {
    final sender = TxSenderData(
      keyring.current.address,
      keyring.current.pubKey,
    );
    final txInfo = TxInfoData(module, "registerDevice", sender);
    try {
      final hash = await plugin.sdk.api.tx.signAndSend(
        txInfo,
        [
          "0x$pubkey",
          producerId,
          brandId,
        ],
        password,
        onStatusChange: (status) {
          LogUtil.d(status);
        },
      );
      LogUtil.d('sendTx txid: ${hash.toString()}');
    } catch (err) {
      LogUtil.d('sendTx failed: ${err.toString()}');
      return "";
    }

    return "";
  }

  Future<List<VFEDetail>?> getVFEDetailsByAddress(
      String address, int brandId) async {

    final res =
    await plugin.sdk.api.service.webView?.evalJavascript('vfe.getVFEDetailsByAddress(api, "$address", $brandId)');

    if (res != null) {
      List<VFEDetail> list = res.map((e) => VFEDetail.fromJson(e)).toList();
      return list;
    } else {
      return null;
    }
  }
}
