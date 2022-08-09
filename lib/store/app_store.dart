import 'package:get_storage/get_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:toearnfun_flutter_app/store/account.dart';

class AppStore {
  AppStore(this.storage);

  final GetStorage storage;

  late AccountStore account;

  @action
  Future<void> init() async {
    account = AccountStore();
  }
}
