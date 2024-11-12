import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:toearnfun_flutter_app/types/user.dart';
import 'package:toearnfun_flutter_app/types/vfe_brand.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

part 'vfe.g.dart';

class VFEStore extends _VFEStore with _$VFEStore {
  VFEStore(GetStorage storage) : super(storage);
}

abstract class _VFEStore with Store {
  _VFEStore(this.storage);

  final GetStorage storage;

  final String userCurrentVFEKey = 'user_current_vfe';
  final String userVFEListKey = 'user_vfe_list';
  final String userStateKey = 'user_state';

  @observable
  User userState = User();

  @observable
  VFEDetail current = VFEDetail();

  @observable
  ObservableList<VFEDetail> userVFEList = ObservableList<VFEDetail>();

  @observable
  ObservableList<VFEBrand> allVFEBrands = ObservableList<VFEBrand>();

  @observable
  int lastEnergyRecovery = 0;

  TokenBalanceData? incentiveToken;

  @action
  void clearUserVFE() {
    userVFEList.clear();
  }

  @action
  void loadCurrentVFE(String? pubKey) {
    final key = '${userCurrentVFEKey}_$pubKey';
    final data = storage.read(key);
    if (data != null) {
      current = VFEDetail.fromJson(data);
    } else {
      current = VFEDetail();
    }
  }

  @action
  Future<void> updateUserCurrent(String? pubKey, VFEDetail vfe) async {
    current = vfe;
    final key = '${userCurrentVFEKey}_$pubKey';
    await storage.write(key, vfe.toJson());
  }

  @action
  Future<void> updateUserVFE(String? pubKey, VFEDetail value) async {
    for (var vfe in userVFEList) {
      if (vfe.brandId == value.brandId && vfe.itemId == value.itemId) {
        vfe = value;
      }
    }
  }

  @action
  Future<void> addUserVFEList(String? pubKey, List<VFEDetail> vfeList) async {
    // userVFEList.clear();
    for (var vfe in vfeList) {
      userVFEList.add(vfe);
      if (
      current.itemId == vfe.itemId
      // || current.itemId == null
      ) {
        //update user current vfe
        updateUserCurrent(pubKey, vfe);
      }
    }

    List<Map<String, dynamic>> rawData =
    userVFEList.map((e) => e.toJson()).toList();

    final key = '${userVFEListKey}_$pubKey';
    await storage.write(key, rawData);
  }

  @action
  void loadUserState() {
    final key = userStateKey;
    final data = storage.read(key);
    if (data != null) {
      userState = User.fromJson(data);
    } else {
      userState = User();
    }
  }

  @action
  Future<void> updateUserState(User state) async {
    userState = state;
    final key = userStateKey;
    await storage.write(key, state.toJson());
  }

  @action
  Future<void> updateLastEnergyRecovery(int value) async {
    lastEnergyRecovery = value;
  }

  VFEDetail? getUserVFEByDeviceKey(String deviceKey) {
    if (deviceKey.isEmpty) {
      return null;
    }
    for (var vfe in userVFEList) {
      final key = vfe.deviceKey.replaceFirst('0x', '');
      if (key == deviceKey) {
        return vfe;
      }
    }
    return null;
  }
}
