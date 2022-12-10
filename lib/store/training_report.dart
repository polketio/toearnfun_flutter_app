import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:mobx/mobx.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toearnfun_flutter_app/types/training_report.dart';

part 'training_report.g.dart';

class TrainingReportStore extends _TrainingReportStore with _$TrainingReportStore {
  TrainingReportStore(GetStorage storage) : super(storage);
}

abstract class _TrainingReportStore with Store {
  _TrainingReportStore(this.storage);

  final GetStorage storage;

  final String userTrainingReportKey = 'user_training_report_list';
  final String userLastReportTimeKey = 'user_last_report_time';

  @observable
  List<SkipResultData> userTrainingReportList =[];

  int lastReportTime = 0;

  Future<void> setLastReportTime(int lastReportTime) async {
    await storage.write(userLastReportTimeKey, lastReportTime);
  }

  int getLastReportTime() {
    return storage.read(userLastReportTimeKey);
  }

  @action
  Future<void> addTrainingReport(SkipResultData report) async {
    //todo: this is a bug which will clear the local cache
    userTrainingReportList.add(report);
    List<Map<String, dynamic>> rawData =
    userTrainingReportList.map((e) => e.toJson()).toList();
    await storage.write(userTrainingReportKey, rawData);
  }

  @action
  void loadTrainingReportList() {
    List? cache = storage.read(userTrainingReportKey);
    if (cache!=null) {
      LogUtil.d('SkipResultData cache: $cache');
      userTrainingReportList = cache.map((i) {
        return SkipResultData.fromJson(i);
      }).toList();
    } else {
      userTrainingReportList = [];
    }

  }

}