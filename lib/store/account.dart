import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:polkawallet_sdk/api/types/recoveryInfo.dart';
import 'package:polkawallet_sdk/api/types/walletConnect/pairingData.dart';

part 'account.g.dart';

class AccountStore extends _AccountStore with _$AccountStore {
  AccountStore(FlutterSecureStorage secureStorage) : super(secureStorage);
}

abstract class _AccountStore with Store {
  _AccountStore(this.secureStorage);

  final FlutterSecureStorage secureStorage;

  final _userWalletPasswordKey = 'user_wallet_password_';

  @observable
  AccountCreate newAccount = AccountCreate();

  @observable
  bool accountCreated = false;

  @observable
  ObservableMap<int, Map<String, String>> pubKeyAddressMap =
      ObservableMap<int, Map<String, String>>();

  @observable
  ObservableMap<String, String> addressIconsMap =
      ObservableMap<String, String>();

  @observable
  RecoveryInfo recoveryInfo = RecoveryInfo();

  @observable
  bool walletConnectPairing = false;

  @observable
  ObservableList<WCPairedData> wcSessions = ObservableList<WCPairedData>();

  @action
  void setNewAccount(String name, String password) {
    newAccount.name = name;
    newAccount.password = password;
  }

  @action
  void setNewAccountKey(String key) {
    newAccount.key = key;
  }

  @action
  void resetNewAccount() {
    newAccount = AccountCreate();
  }

  @action
  void setAccountCreated() {
    accountCreated = true;
  }

  @action
  void setPubKeyAddressMap(Map<String, Map> data) {
    data.keys.forEach((ss58) {
      // get old data map
      Map<String, String> addresses =
          Map.of(pubKeyAddressMap[int.parse(ss58)] ?? {});
      // set new data
      Map.of(data[ss58] ?? {}).forEach((k, v) {
        addresses[k] = v;
      });
      // update state
      pubKeyAddressMap[int.parse(ss58)] = addresses;
    });
  }

  @action
  void setAddressIconsMap(List list) {
    list.forEach((i) {
      addressIconsMap[i[0]] = i[1];
    });
  }

  @action
  void setAccountRecoveryInfo(RecoveryInfo data) {
    recoveryInfo = data;
  }

  @action
  void setWCPairing(bool pairing) {
    walletConnectPairing = pairing;
  }

  @action
  void setWCSessions(List<WCPairedData> sessions) {
    wcSessions = ObservableList.of(sessions);
  }

  @action
  void createWCSession(WCPairedData session) {
    wcSessions.add(session);
  }

  @action
  void deleteWCSession(WCPairedData session) {
    wcSessions.removeWhere((e) => e.topic == session.topic);
  }

  Future<void> saveUserWalletPassword(String pubkey, String password) async {
    await secureStorage.write(key: '$_userWalletPasswordKey$pubkey', value: password);
  }

  Future<String?> getUserWalletPassword(String pubkey) async {
    return await secureStorage.read(key: '$_userWalletPasswordKey$pubkey');
  }
}

class AccountCreate extends _AccountCreate with _$AccountCreate {}

abstract class _AccountCreate with Store {
  @observable
  String name = '';

  @observable
  String password = '';

  @observable
  String key = '';
}
