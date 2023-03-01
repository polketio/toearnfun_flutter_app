import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:toearnfun_flutter_app/types/vfe_order.dart';

part 'vfe_order.g.dart';

class VFEOrderStore extends _VFEOrderStore with _$VFEOrderStore {
  VFEOrderStore(GetStorage storage) : super(storage);
}

abstract class _VFEOrderStore with Store {
  _VFEOrderStore(this.storage);

  final GetStorage storage;

  @observable
  ObservableList<Order> marketOrders = ObservableList<Order>();

  @action
  void removeOrder(int orderId) {
    marketOrders.removeWhere((e) => e.id == orderId);
  }
}