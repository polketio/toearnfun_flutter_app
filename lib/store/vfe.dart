import 'package:get_storage/get_storage.dart';
import 'package:mobx/mobx.dart';
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

  @observable
  VFEDetail? current;

  @observable
  ObservableList<VFEDetail> userVFEList = ObservableList<VFEDetail>();

  @observable
  ObservableList<VFEBrand> allVFEBrands = ObservableList<VFEBrand>();

  @action
  void clearUserVFE() {
    userVFEList.clear();
  }

  @action
  Future<void> addUserVFE(VFEDetail vfe) async {
    for (var existed in userVFEList) {
      if (existed.itemId == vfe.itemId && existed.brandId == vfe.brandId) {
        return;
      }
    }
    userVFEList.add(vfe);
  }

  @action
  void loadUserCurrent(String? pubKey) {
    final key = '${userCurrentVFEKey}_$pubKey';
    current = storage.read(key);
  }

  @action
  Future<void> setUserCurrent(String? pubKey, VFEDetail vfe) async {
    current = vfe;
    final key = '${userCurrentVFEKey}_$pubKey';
    await storage.write(key, vfe);
  }
}
