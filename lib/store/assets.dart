import 'package:get_storage/get_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore(GetStorage storage) : super(storage);
}

abstract class _AssetsStore with Store {
  _AssetsStore(this.storage);

  final GetStorage storage;
  final String cacheTxsTransferKey = 'transfer_txs';

  @observable
  Map<String, TokenBalanceData> assetBalanceMap =
      Map<String, TokenBalanceData>();

  @action
  void setTokenBalanceMap(List<TokenBalanceData> list) {
    final data = Map<String, TokenBalanceData>();
    list.forEach((e) {
      if (e.symbol == null) {
        throw Exception('asset symbol is empty');
      }
      data[e.symbol!] = e;
    });
    assetBalanceMap = data;
  }

  @action
  void addTx(Map tx, KeyPairData acc) {
    //TODO: add tx

    final cached = storage.read(cacheTxsTransferKey);
    List list = cached[acc.pubKey];
    // if (list != null) {
    //   list.add(txData);
    // } else {
    //   list = [txData];
    // }
    cached[acc.pubKey] = list;
    storage.write(cacheTxsTransferKey, cached);
  }

  @action
  void loadCache(String? pubKey) {
    // if (pubKey == null || pubKey.isEmpty) return;
    //
    // final cached = storage.read(cacheTxsTransferKey);
    // final list = cached[pubKey] as List;
    // if (list != null) {
    //   txs = ObservableList<TransferData>.of(
    //       list.map((e) => TransferData.fromJson(Map<String, dynamic>.from(e))));
    // } else {
    //   txs = ObservableList<TransferData>();
    // }
  }
}
