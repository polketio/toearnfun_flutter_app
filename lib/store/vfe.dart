import 'package:get_storage/get_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

part 'vfe.g.dart';

class VFEStore extends _VFEStore with _$VFEStore {
  VFEStore(GetStorage storage) : super(storage);
}

abstract class _VFEStore with Store {
  _VFEStore(this.storage);

  final GetStorage storage;

  final String userVFEListKey = 'user_vfe_list';

  @observable
  VFEDetail? currentVFE;

  @observable
  ObservableList<VFEDetail> userVFEList =
  ObservableList<VFEDetail>();

  @action
  Future<void> addUserVFE(String user, VFEDetail vfe) async {
    // if (_connectedDevices.isEmpty) {
    //   loadConnectedDevices();
    // }
    //
    // for (var d in _connectedDevices) {
    //   if (d.mac == device.mac) {
    //     return;
    //   }
    // }
    //
    // _connectedDevices.add(device);
    // await storage.write(connectedDevicesKey, _connectedDevices);
  }
}