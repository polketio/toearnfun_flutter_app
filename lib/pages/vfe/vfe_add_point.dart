import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:toearnfun_flutter_app/common/common.dart';
import 'package:toearnfun_flutter_app/plugin.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';
import 'package:toearnfun_flutter_app/utils/hex_color.dart';

class VFEAddPointView extends StatefulWidget {
  VFEAddPointView(this.plugin, this.keyring);

  final PluginPolket plugin;
  final Keyring keyring;

  static const String route = '/toearnfun/vfe/vfe_add_point';

  @override
  State<VFEAddPointView> createState() => _VFEAddPointViewState();
}

class _VFEAddPointViewState extends State<VFEAddPointView> {
  final _backgroundColor = HexColor('#956DFD');

  VFEDetail? vfeDetail;
  VFEAbility newAbility = VFEAbility();
  VFEAbility currentAbility = VFEAbility();
  int availablePoints = 0;
  int changePoints = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      setState(() {
        vfeDetail = data['vfeDetail'];
        newAbility = VFEAbility.fromJson(
            (vfeDetail?.currentAbility ?? VFEAbility()).toJson());
        currentAbility = vfeDetail?.currentAbility ?? VFEAbility();
        availablePoints = vfeDetail?.availablePoints ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _backgroundColor,
        appBar: getAppBarView(),
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.only(top: 28.h),
                padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 28.h),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(flex: 0, child: titleView()),
                      Expanded(flex: 1, child: abilityView()),
                      Expanded(flex: 0, child: buttonView(context)),
                    ]))));
  }

  PreferredSizeWidget getAppBarView() {
    return AppBar(
      toolbarOpacity: 1,
      bottomOpacity: 0,
      elevation: 0,
      backgroundColor: _backgroundColor,
      leading: MyBackButton(onBack: () {
        vfeDetail?.currentAbility = currentAbility;
        Navigator.of(context).pop();
      }),
      centerTitle: true,
      title: const Text('Add Points', style: TextStyle(color: Colors.white)),
    );
  }

  Widget titleView() {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text('Available points:', style: TextStyle(fontSize: 20)),
      Padding(padding: EdgeInsets.only(left: 16.w)),
      Text('$availablePoints',
          style: TextStyle(fontSize: 28, color: _backgroundColor)),
    ]);
  }

  Widget abilityView() {
    return Container(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getAttributesItemView(0, 'assets/images/icon-Efficiency.png',
                'Efficiency', newAbility.efficiency, currentAbility.efficiency),
            getAttributesItemView(1, 'assets/images/icon-Speed-ab.png', 'Skill',
                newAbility.skill, currentAbility.skill),
            getAttributesItemView(2, 'assets/images/icon-Luck.png', 'Luck',
                newAbility.luck, currentAbility.luck),
            getAttributesItemView(3, 'assets/images/icon-Resilience.png',
                'Durable', newAbility.durable, currentAbility.durable),
          ]),
    );
  }

  Widget getAttributesItemView(
      int index, String icon, String text, int newValue, int currentValue) {
    Color addColor, subColor;
    if (availablePoints > 0) {
      addColor = _backgroundColor;
    } else {
      addColor = Colors.black26;
    }
    if (newValue <= currentValue) {
      subColor = Colors.black26;
    } else {
      subColor = _backgroundColor;
    }
    return SizedBox(
        width: double.infinity,
        height: 60.h,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //[icon, text, bar, number]
              // IconText(icon, text),
              BrnIconButton(
                name: text,
                style: TextStyle(fontSize: 16),
                direction: Direction.left,
                padding: 4,
                iconWidget: Image.asset(icon),
                widgetHeight: 30.h,
                widgetWidth: 100.w,
                iconHeight: 16.h,
                iconWidth: 16.w,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Material(
                      color: subColor,
                      child: InkWell(
                        splashColor: subColor,
                        onTap: () {
                          editNewPoint(index, newValue, currentValue, false);
                        },
                        child: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 30.w,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 44.w,
                    child: Text(
                      '$newValue',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ClipOval(
                    child: Material(
                      color: addColor,
                      child: InkWell(
                        splashColor: addColor,
                        onTap: () {
                          editNewPoint(index, newValue, currentValue, true);
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30.w,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ]));
  }

  Widget buttonView(BuildContext context) {
    Function()? onPressed;
    Color btnColor;
    if (changePoints <= 0) {
      onPressed = null;
      btnColor = Colors.black26;
    } else {
      onPressed = () async {
        confirmAddPoints(context);
      };
      btnColor = _backgroundColor;
    }

    return SizedBox(
        height: 50.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all(btnColor),
            alignment: Alignment.center,
          ),
          child: const Text('Confirm',
              style: TextStyle(fontSize: 24, color: Colors.white)),
        ));
  }

  editNewPoint(int index, int value, int current, bool isAdd) {
    setState(() {
      final maxPoint = vfeDetail?.availablePoints ?? 0;
      if (isAdd) {
        if (availablePoints == 0) {
          return;
        }
        availablePoints = availablePoints - 1;
        value = value + 1;
        changePoints = changePoints + 1;
      } else {
        if (availablePoints + 1 > maxPoint) {
          return;
        }
        if (value - 1 < current) {
          return;
        }
        value = value - 1;
        availablePoints = availablePoints + 1;
        changePoints = changePoints - 1;
      }

      switch (index) {
        case 0:
          newAbility.efficiency = value;
          break;
        case 1:
          newAbility.skill = value;
          break;
        case 2:
          newAbility.luck = value;
          break;
        case 3:
          newAbility.durable = value;
          break;
      }
    });
  }

  confirmAddPoints(BuildContext context) async {
    if (vfeDetail == null) {
      BrnToast.show('VFE is not existed', context);
      return;
    }

    BrnLoadingDialog.show(context,
        content: 'Updating...', barrierDismissible: false);

    final password = await widget.plugin.api.account.getPassword(
      context,
      widget.keyring.current,
    );
    final increaseAbility = VFEAbility();
    increaseAbility.efficiency =
        newAbility.efficiency - currentAbility.efficiency;
    increaseAbility.skill = newAbility.skill - currentAbility.skill;
    increaseAbility.luck = newAbility.luck - currentAbility.luck;
    increaseAbility.durable = newAbility.durable - currentAbility.durable;

    final result = await widget.plugin.api.vfe.increaseAbility(
        vfeDetail!.brandId!, vfeDetail!.itemId!, increaseAbility, password);

    if (!mounted) return;
    BrnLoadingDialog.dismiss(context);

    if (!result.success) {
      // update  state
      BrnToast.show(result.error, context);
    } else {
      BrnToast.show('Update successfully', context);

      vfeDetail!.currentAbility = newAbility;
      vfeDetail!.availablePoints = availablePoints;
      widget.plugin.store.vfe
          .updateUserVFE(widget.keyring.current.pubKey, vfeDetail!);
      Navigator.pop(context, vfeDetail);
    }
  }
}
