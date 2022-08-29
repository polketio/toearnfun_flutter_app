// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AssetsStore on _AssetsStore, Store {
  late final _$assetBalanceMapAtom =
      Atom(name: '_AssetsStore.assetBalanceMap', context: context);

  @override
  Map<String, TokenBalanceData> get assetBalanceMap {
    _$assetBalanceMapAtom.reportRead();
    return super.assetBalanceMap;
  }

  @override
  set assetBalanceMap(Map<String, TokenBalanceData> value) {
    _$assetBalanceMapAtom.reportWrite(value, super.assetBalanceMap, () {
      super.assetBalanceMap = value;
    });
  }

  late final _$_AssetsStoreActionController =
      ActionController(name: '_AssetsStore', context: context);

  @override
  void setTokenBalanceMap(List<TokenBalanceData> list) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setTokenBalanceMap');
    try {
      return super.setTokenBalanceMap(list);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addTx(Map<dynamic, dynamic> tx, KeyPairData acc) {
    final _$actionInfo =
        _$_AssetsStoreActionController.startAction(name: '_AssetsStore.addTx');
    try {
      return super.addTx(tx, acc);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void loadCache(String? pubKey) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.loadCache');
    try {
      return super.loadCache(pubKey);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
assetBalanceMap: ${assetBalanceMap}
    ''';
  }
}
