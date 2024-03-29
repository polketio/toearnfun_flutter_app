import 'dart:async';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:polkawallet_sdk/api/types/recoveryInfo.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/components/passwordInputDialog.dart';
import 'package:polkawallet_ui/components/v3/dialog.dart';
import 'package:toearnfun_flutter_app/common/consts.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/store/account.dart';

class PolketApiAccount {
  PolketApiAccount(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  final _biometricEnabledKey = 'biometric_enabled_';
  final _biometricPasswordKey = 'biometric_password_';

  Future<Map> importAccount({
    KeyType keyType = KeyType.mnemonic,
    CryptoType cryptoType = CryptoType.sr25519,
    String derivePath = '',
    bool isFromCreatePage = false,
  }) async {
    final acc = plugin.store.account.newAccount ?? AccountCreate();
    if (isFromCreatePage &&
        (acc.name == null ||
            acc.name.isEmpty ||
            acc.password == null ||
            acc.password.isEmpty)) {
      throw Exception('create account failed');
    }
    final res = await plugin.sdk.api.keyring.importAccount(
      keyring,
      keyType: keyType,
      cryptoType: cryptoType,
      derivePath: derivePath,
      key: acc.key,
      name: acc.name,
      password: acc.password,
    );
    return res!;
  }

  Future<KeyPairData> addAccount({
    required Map json,
    KeyType keyType = KeyType.mnemonic,
    CryptoType cryptoType = CryptoType.sr25519,
    String derivePath = '',
    bool isFromCreatePage = false,
  }) async {
    final acc = plugin.store.account.newAccount ?? AccountCreate();
    if (isFromCreatePage &&
        (acc.name == null ||
            acc.name.isEmpty ||
            acc.password == null ||
            acc.password.isEmpty)) {
      throw Exception('save account failed');
    }
    final res = await plugin.sdk.api.keyring.addAccount(
      keyring,
      keyType: keyType,
      acc: json,
      password: acc.password,
    );
    return res;
  }

  void setBiometricEnabled(String pubKey) {
    plugin.store.storage.write(
        '$_biometricEnabledKey$pubKey', DateTime.now().millisecondsSinceEpoch);
  }

  // void setBiometricDisabled(String pubKey) {
  //   apiRoot.store.storage.write('$_biometricEnabledKey$pubKey',
  //       DateTime.now().millisecondsSinceEpoch - SECONDS_OF_DAY * 7000);
  // }

  // Actively turn off the function and will not be automatically unlocked again
  void closeBiometricDisabled(String pubKey) {
    plugin.store.storage.write('$_biometricEnabledKey$pubKey', 0);
  }

  bool isCloseBiometricDisabled(String pubKey) {
    final timestamp = plugin.store.storage.read('$_biometricEnabledKey$pubKey');
    if (timestamp == null || timestamp == 0) {
      return true;
    }
    return false;
  }

  bool getBiometricEnabled(String pubKey) {
    final timestamp = plugin.store.storage.read('$_biometricEnabledKey$pubKey');
    // we cache user's password with biometric for 7 days.
    if (timestamp != null &&
        timestamp + SECONDS_OF_DAY * 7000 >
            DateTime.now().millisecondsSinceEpoch) {
      return true;
    }
    return false;
  }

  Future<BiometricStorageFile> getBiometricPassStoreFile(
    BuildContext context,
    String pubKey,
  ) async {
    return BiometricStorage().getStorage(
      '$_biometricPasswordKey$pubKey',
      options:
          StorageFileInitOptions(authenticationValidityDurationSeconds: 30),
      // androidPromptInfo: AndroidPromptInfo(
      //   title:
      //       I18n.of(context).getDic(i18n_full_dic_app, 'account')['unlock.bio'],
      //   negativeButton:
      //       I18n.of(context).getDic(i18n_full_dic_ui, 'common')['cancel'],
      // ),
    );
  }

  Future<String?> getPasswordWithBiometricAuth(
      BuildContext context, String pubKey) async {
    final response = await BiometricStorage().canAuthenticate();

    final supportBiometric = response == CanAuthenticateResponse.success;
    if (supportBiometric) {
      final isBiometricAuthorized = getBiometricEnabled(pubKey);
      // we prompt biometric auth here if device supported
      // and user authorized to use biometric.
      if (isBiometricAuthorized) {
        final authStorage = await getBiometricPassStoreFile(context, pubKey);
        try {
          final result = await authStorage.read();
          print('read password from authStorage: $result');
          if (result != null) {
            return result;
          }
        } catch (err) {
          print(err);
          return "can't";
        }
      }
    } else {
      return "can't";
    }
    return null;
  }

  Future<String?> getPassword(
      BuildContext context, KeyPairData acc, [bool needInteract = false]) async {
    if (needInteract) {
      final bioPass = await getPasswordWithBiometricAuth(context, acc.pubKey!);
      final isClose = isCloseBiometricDisabled(acc.pubKey!);
      if (bioPass == null && !isClose) {
        await showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return PolkawalletAlertDialog(
              title: Text('Note'),
              content: Text(
                  'Enter the password to activate fingerprint/face ID due to the biometrics has expired.'),
              actions: <Widget>[
                PolkawalletActionSheetAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
      String? password = await showCupertinoDialog(
        context: context,
        builder: (_) {
          return PasswordInputDialog(
            plugin.sdk.api,
            title: Text('Unlock Account with Password'),
            account: acc,
            userPass: bioPass == "can't" ? null : bioPass,
          );
        },
      );
      if (bioPass == null && !isClose && password != null) {
        setBiometricEnabled(acc.pubKey!);
      }
      return password;
    } else {
      String? password =
          await plugin.store.account.getUserWalletPassword(acc.pubKey!);
      return password;
    }
  }

  Future<void> queryAddressIcons(List addresses) async {
    addresses.retainWhere(
        (e) => !plugin.store!.account.addressIconsMap.containsKey(e));
    if (addresses.length == 0) return;

    final icons = await plugin.sdk.api.account.getAddressIcons(addresses);
    plugin.store.account.setAddressIconsMap(icons!);
  }

  Future<RecoveryInfo> queryRecoverable(String address) async {
//    address = 'J4sW13h2HNerfxTzPGpLT66B3HVvuU32S6upxwSeFJQnAzg';
    final res = await plugin.sdk.api.recovery.queryRecoverable(address);
    plugin.store!.account.setAccountRecoveryInfo(res!);

    if (res != null && res!.friends!.length > 0) {
      queryAddressIcons(res!.friends!);
    }
    return res;
  }
}
