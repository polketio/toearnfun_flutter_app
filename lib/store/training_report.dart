import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:mobx/mobx.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realm/realm.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';

part 'training_report.g.dart';

class TrainingReportStore extends _TrainingReportStore
    with _$TrainingReportStore {
  TrainingReportStore(GetStorage storage, Realm realm) : super(storage, realm);
}

abstract class _TrainingReportStore with Store {
  _TrainingReportStore(this.storage, this.realm);

  final GetStorage storage;
  final Realm realm;

  final String userTrainingReportKey = 'user_training_report_list';
  final String userLastReportTimeKey = 'user_last_report_time';

  int lastReportTime = 0;

  Future<void> setLastReportTime(int lastReportTime) async {
    await storage.write(userLastReportTimeKey, lastReportTime);
  }

  int getLastReportTime() {
    return storage.read(userLastReportTimeKey);
  }

  List<TrainingReport> loadTrainingReportList() {
    final list = realm.query<TrainingReport>(
        'TRUEPREDICATE SORT(reportTime DESC)');
    return list.toList();
  }

  void addTrainingReport(TrainingReport data, [bool update = false]) {
    realm.write(() {
      realm.add(data, update: update);
    });
  }

  void addTrainingReward(TrainingReward data, [bool update = false]) {
    realm.write(() {
      realm.add(data, update: update);
    });
  }
}