import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toearnfun_flutter_app/app.dart';
import 'package:toearnfun_flutter_app/common/consts.dart';

void main() async {
  await GetStorage.init(get_storage_container);

  runApp(ToEarnFunApp(BuildTargets.apk));
}
