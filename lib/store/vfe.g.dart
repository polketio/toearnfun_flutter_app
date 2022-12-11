// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vfe.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VFEStore on _VFEStore, Store {
  late final _$userStateAtom =
      Atom(name: '_VFEStore.userState', context: context);

  @override
  User get userState {
    _$userStateAtom.reportRead();
    return super.userState;
  }

  @override
  set userState(User value) {
    _$userStateAtom.reportWrite(value, super.userState, () {
      super.userState = value;
    });
  }

  late final _$currentAtom = Atom(name: '_VFEStore.current', context: context);

  @override
  VFEDetail get current {
    _$currentAtom.reportRead();
    return super.current;
  }

  @override
  set current(VFEDetail value) {
    _$currentAtom.reportWrite(value, super.current, () {
      super.current = value;
    });
  }

  late final _$userVFEListAtom =
      Atom(name: '_VFEStore.userVFEList', context: context);

  @override
  ObservableList<VFEDetail> get userVFEList {
    _$userVFEListAtom.reportRead();
    return super.userVFEList;
  }

  @override
  set userVFEList(ObservableList<VFEDetail> value) {
    _$userVFEListAtom.reportWrite(value, super.userVFEList, () {
      super.userVFEList = value;
    });
  }

  late final _$allVFEBrandsAtom =
      Atom(name: '_VFEStore.allVFEBrands', context: context);

  @override
  ObservableList<VFEBrand> get allVFEBrands {
    _$allVFEBrandsAtom.reportRead();
    return super.allVFEBrands;
  }

  @override
  set allVFEBrands(ObservableList<VFEBrand> value) {
    _$allVFEBrandsAtom.reportWrite(value, super.allVFEBrands, () {
      super.allVFEBrands = value;
    });
  }

  late final _$updateUserCurrentAsyncAction =
      AsyncAction('_VFEStore.updateUserCurrent', context: context);

  @override
  Future<void> updateUserCurrent(String? pubKey, VFEDetail vfe) {
    return _$updateUserCurrentAsyncAction
        .run(() => super.updateUserCurrent(pubKey, vfe));
  }

  late final _$addUserVFEListAsyncAction =
      AsyncAction('_VFEStore.addUserVFEList', context: context);

  @override
  Future<void> addUserVFEList(String? pubKey, List<VFEDetail> vfeList) {
    return _$addUserVFEListAsyncAction
        .run(() => super.addUserVFEList(pubKey, vfeList));
  }

  late final _$updateUserStateAsyncAction =
      AsyncAction('_VFEStore.updateUserState', context: context);

  @override
  Future<void> updateUserState(User state) {
    return _$updateUserStateAsyncAction.run(() => super.updateUserState(state));
  }

  late final _$_VFEStoreActionController =
      ActionController(name: '_VFEStore', context: context);

  @override
  void clearUserVFE() {
    final _$actionInfo =
        _$_VFEStoreActionController.startAction(name: '_VFEStore.clearUserVFE');
    try {
      return super.clearUserVFE();
    } finally {
      _$_VFEStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void loadCurrentVFE(String? pubKey) {
    final _$actionInfo = _$_VFEStoreActionController.startAction(
        name: '_VFEStore.loadCurrentVFE');
    try {
      return super.loadCurrentVFE(pubKey);
    } finally {
      _$_VFEStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void loadUserState() {
    final _$actionInfo = _$_VFEStoreActionController.startAction(
        name: '_VFEStore.loadUserState');
    try {
      return super.loadUserState();
    } finally {
      _$_VFEStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
userState: ${userState},
current: ${current},
userVFEList: ${userVFEList},
allVFEBrands: ${allVFEBrands}
    ''';
  }
}
