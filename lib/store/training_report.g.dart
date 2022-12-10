// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_report.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TrainingReportStore on _TrainingReportStore, Store {
  late final _$userTrainingReportListAtom = Atom(
      name: '_TrainingReportStore.userTrainingReportList', context: context);

  @override
  List<SkipResultData> get userTrainingReportList {
    _$userTrainingReportListAtom.reportRead();
    return super.userTrainingReportList;
  }

  @override
  set userTrainingReportList(List<SkipResultData> value) {
    _$userTrainingReportListAtom
        .reportWrite(value, super.userTrainingReportList, () {
      super.userTrainingReportList = value;
    });
  }

  late final _$addTrainingReportAsyncAction =
      AsyncAction('_TrainingReportStore.addTrainingReport', context: context);

  @override
  Future<void> addTrainingReport(SkipResultData report) {
    return _$addTrainingReportAsyncAction
        .run(() => super.addTrainingReport(report));
  }

  late final _$_TrainingReportStoreActionController =
      ActionController(name: '_TrainingReportStore', context: context);

  @override
  void loadTrainingReportList() {
    final _$actionInfo = _$_TrainingReportStoreActionController.startAction(
        name: '_TrainingReportStore.loadTrainingReportList');
    try {
      return super.loadTrainingReportList();
    } finally {
      _$_TrainingReportStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
userTrainingReportList: ${userTrainingReportList}
    ''';
  }
}
