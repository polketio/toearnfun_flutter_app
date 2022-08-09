// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AccountStore on _AccountStore, Store {
  late final _$newAccountAtom =
      Atom(name: '_AccountStore.newAccount', context: context);

  @override
  AccountCreate get newAccount {
    _$newAccountAtom.reportRead();
    return super.newAccount;
  }

  @override
  set newAccount(AccountCreate value) {
    _$newAccountAtom.reportWrite(value, super.newAccount, () {
      super.newAccount = value;
    });
  }

  late final _$accountCreatedAtom =
      Atom(name: '_AccountStore.accountCreated', context: context);

  @override
  bool get accountCreated {
    _$accountCreatedAtom.reportRead();
    return super.accountCreated;
  }

  @override
  set accountCreated(bool value) {
    _$accountCreatedAtom.reportWrite(value, super.accountCreated, () {
      super.accountCreated = value;
    });
  }

  late final _$pubKeyAddressMapAtom =
      Atom(name: '_AccountStore.pubKeyAddressMap', context: context);

  @override
  ObservableMap<int, Map<String, String>> get pubKeyAddressMap {
    _$pubKeyAddressMapAtom.reportRead();
    return super.pubKeyAddressMap;
  }

  @override
  set pubKeyAddressMap(ObservableMap<int, Map<String, String>> value) {
    _$pubKeyAddressMapAtom.reportWrite(value, super.pubKeyAddressMap, () {
      super.pubKeyAddressMap = value;
    });
  }

  late final _$addressIconsMapAtom =
      Atom(name: '_AccountStore.addressIconsMap', context: context);

  @override
  ObservableMap<String, String> get addressIconsMap {
    _$addressIconsMapAtom.reportRead();
    return super.addressIconsMap;
  }

  @override
  set addressIconsMap(ObservableMap<String, String> value) {
    _$addressIconsMapAtom.reportWrite(value, super.addressIconsMap, () {
      super.addressIconsMap = value;
    });
  }

  late final _$recoveryInfoAtom =
      Atom(name: '_AccountStore.recoveryInfo', context: context);

  @override
  RecoveryInfo get recoveryInfo {
    _$recoveryInfoAtom.reportRead();
    return super.recoveryInfo;
  }

  @override
  set recoveryInfo(RecoveryInfo value) {
    _$recoveryInfoAtom.reportWrite(value, super.recoveryInfo, () {
      super.recoveryInfo = value;
    });
  }

  late final _$walletConnectPairingAtom =
      Atom(name: '_AccountStore.walletConnectPairing', context: context);

  @override
  bool get walletConnectPairing {
    _$walletConnectPairingAtom.reportRead();
    return super.walletConnectPairing;
  }

  @override
  set walletConnectPairing(bool value) {
    _$walletConnectPairingAtom.reportWrite(value, super.walletConnectPairing,
        () {
      super.walletConnectPairing = value;
    });
  }

  late final _$wcSessionsAtom =
      Atom(name: '_AccountStore.wcSessions', context: context);

  @override
  ObservableList<WCPairedData> get wcSessions {
    _$wcSessionsAtom.reportRead();
    return super.wcSessions;
  }

  @override
  set wcSessions(ObservableList<WCPairedData> value) {
    _$wcSessionsAtom.reportWrite(value, super.wcSessions, () {
      super.wcSessions = value;
    });
  }

  late final _$_AccountStoreActionController =
      ActionController(name: '_AccountStore', context: context);

  @override
  void setNewAccount(String name, String password) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setNewAccount');
    try {
      return super.setNewAccount(name, password);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNewAccountKey(String key) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setNewAccountKey');
    try {
      return super.setNewAccountKey(key);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetNewAccount() {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.resetNewAccount');
    try {
      return super.resetNewAccount();
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountCreated() {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAccountCreated');
    try {
      return super.setAccountCreated();
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPubKeyAddressMap(Map<String, Map<dynamic, dynamic>> data) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setPubKeyAddressMap');
    try {
      return super.setPubKeyAddressMap(data);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAddressIconsMap(List<dynamic> list) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAddressIconsMap');
    try {
      return super.setAddressIconsMap(list);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountRecoveryInfo(RecoveryInfo data) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAccountRecoveryInfo');
    try {
      return super.setAccountRecoveryInfo(data);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWCPairing(bool pairing) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setWCPairing');
    try {
      return super.setWCPairing(pairing);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWCSessions(List<WCPairedData> sessions) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setWCSessions');
    try {
      return super.setWCSessions(sessions);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void createWCSession(WCPairedData session) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.createWCSession');
    try {
      return super.createWCSession(session);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteWCSession(WCPairedData session) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.deleteWCSession');
    try {
      return super.deleteWCSession(session);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
newAccount: ${newAccount},
accountCreated: ${accountCreated},
pubKeyAddressMap: ${pubKeyAddressMap},
addressIconsMap: ${addressIconsMap},
recoveryInfo: ${recoveryInfo},
walletConnectPairing: ${walletConnectPairing},
wcSessions: ${wcSessions}
    ''';
  }
}

mixin _$AccountCreate on _AccountCreate, Store {
  late final _$nameAtom = Atom(name: '_AccountCreate.name', context: context);

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$passwordAtom =
      Atom(name: '_AccountCreate.password', context: context);

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$keyAtom = Atom(name: '_AccountCreate.key', context: context);

  @override
  String get key {
    _$keyAtom.reportRead();
    return super.key;
  }

  @override
  set key(String value) {
    _$keyAtom.reportWrite(value, super.key, () {
      super.key = value;
    });
  }

  @override
  String toString() {
    return '''
name: ${name},
password: ${password},
key: ${key}
    ''';
  }
}
