import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:toearnfun_flutter_app/pages/device/bind_device_tips.dart';

class DeviceType {
  DeviceType(this.uuid, this.name);

  final String uuid;
  final String name;
}

class BindDeviceSelector {
  static Future<List<DeviceType>> getDeviceType() async {
    List<DeviceType> list = [];
    list.add(DeviceType('1', 'Smart Jump Rope J2'));
    return list;
  }

  static Future<void> showDeviceTypesSelector<T>(BuildContext context, int itemIdOfVFE) async {
    final deviceTypes = await getDeviceType();
    List<BrnCommonActionSheetItem> actions = deviceTypes
        .map((e) => BrnCommonActionSheetItem(
              e.name,
              actionStyle: BrnCommonActionSheetItemStyle.normal,
              titleStyle: const TextStyle(fontSize: 18),
            ))
        .toList();

    // 展示actionSheet
    showModalBottomSheet<T>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext ctx) {
          return BrnCommonActionSheet(
            title: 'Choose binding device',
            actions: actions,
            cancelTitle: 'Cancel',
            clickCallBack: (int index, BrnCommonActionSheetItem actionEle) {
              Future.delayed(Duration.zero, () {
                Navigator.of(ctx)
                    .pushNamed(BindDeviceTips.route, arguments: {
                  'itemIdOfVFE': itemIdOfVFE,
                });
              });
            },
          );
        });
  }
}
