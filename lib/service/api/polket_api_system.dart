import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/plugin.dart';

class PolketApiSystem {
  PolketApiSystem(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  final module = 'system';

  final blockNumberChannel = 'blockNumber';

  void unsubscribeBlockNumber() async {
    plugin.sdk.api.unsubscribeMessage(blockNumberChannel);
  }

  Future<void> subscribeBlockNumber(Function(int) callback) async {
    plugin.sdk.api.subscribeMessage(
      'api.query.$module.number',
      [],
      blockNumberChannel,
      (data) {
        callback(int.parse(data));
      },
    );
  }

  int get expectedBlockTime {
    if (plugin.networkConst.isNotEmpty) {
      return int.parse(plugin.networkConst['babe']['expectedBlockTime']);
    } else {
      return 0;
    }
  }
}
