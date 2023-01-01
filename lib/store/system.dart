import 'package:get_storage/get_storage.dart';
import 'package:mobx/mobx.dart';

part 'system.g.dart';

class SystemStore extends _SystemStore with _$SystemStore {
  SystemStore(GetStorage storage) : super(storage);
}

abstract class _SystemStore with Store {
  _SystemStore(this.storage);

  final GetStorage storage;

  @observable
  int currentBlockNumber = 0;


  @action
  Future<void> updateCurrentBlockNumber(int value) async {
    currentBlockNumber = value;
  }
}