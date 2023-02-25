// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vfe_order.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VFEOrderStore on _VFEOrderStore, Store {
  late final _$marketOrdersAtom =
      Atom(name: '_VFEOrderStore.marketOrders', context: context);

  @override
  ObservableList<Order> get marketOrders {
    _$marketOrdersAtom.reportRead();
    return super.marketOrders;
  }

  @override
  set marketOrders(ObservableList<Order> value) {
    _$marketOrdersAtom.reportWrite(value, super.marketOrders, () {
      super.marketOrders = value;
    });
  }

  late final _$_VFEOrderStoreActionController =
      ActionController(name: '_VFEOrderStore', context: context);

  @override
  void removeOrder(int orderId) {
    final _$actionInfo = _$_VFEOrderStoreActionController.startAction(
        name: '_VFEOrderStore.removeOrder');
    try {
      return super.removeOrder(orderId);
    } finally {
      _$_VFEOrderStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
marketOrders: ${marketOrders}
    ''';
  }
}
