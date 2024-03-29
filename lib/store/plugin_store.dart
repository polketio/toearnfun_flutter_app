import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realm/realm.dart';
import 'package:toearnfun_flutter_app/store/account.dart';
import 'package:toearnfun_flutter_app/store/assets.dart';
import 'package:toearnfun_flutter_app/store/devices.dart';
import 'package:toearnfun_flutter_app/store/system.dart';
import 'package:toearnfun_flutter_app/store/training_report.dart';
import 'package:toearnfun_flutter_app/store/vfe.dart';
import 'package:toearnfun_flutter_app/store/vfe_order.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';

class PluginStore {
  static const polket_plugin_cache_key = 'plugin_polket';

  final GetStorage _storage = GetStorage(polket_plugin_cache_key);

  GetStorage get storage => _storage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  FlutterSecureStorage get secureStorage => _secureStorage;

  late Realm _realm;

  Realm get realm => _realm;

  late AssetsStore assets;
  late AccountStore account;
  late DevicesStore devices;
  late VFEStore vfe;
  late VFEOrderStore vfeOrder;
  late TrainingReportStore report;
  late SystemStore system;

  Future<void> init() async {
    await GetStorage.init(polket_plugin_cache_key);

    final config = Configuration.local(
        [TrainingReport.schema, TrainingReward.schema],
        schemaVersion: 4);
    _realm = Realm(config);

    // _storage.erase();
    account = AccountStore(_secureStorage);
    assets = AssetsStore(_storage);
    devices = DevicesStore(_storage);
    vfe = VFEStore(_storage);
    vfeOrder = VFEOrderStore(_storage);
    report = TrainingReportStore(_storage, _realm);
    system = SystemStore(_storage);
  }
}
