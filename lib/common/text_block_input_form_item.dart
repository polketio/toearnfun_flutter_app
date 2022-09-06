
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';

class TextBlockInputFormItem extends BrnTextBlockInputFormItem {
  // const TextBlockInputFormItem({Key? key}) : super(key: key);

  TextBlockInputFormItem(
      {Key? key,
        super.label,
        super.title = "",
        super.subTitle,
        super.tipLabel,
        super.prefixIconType = BrnPrefixIconType.normal,
        super.error = "",
        super.isEdit = true,
        super.isRequire = false,
        super.isPrefixIconEnabled = false,
        super.onAddTap,
        super.onRemoveTap,
        super.onTip,
        super.onChanged,
        super.hint = "请输入",
        super.maxCharCount,
        super.autofocus: false,
        super.inputType,
        super.inputFormatters,
        super.controller,
        super.minLines = 4,
        super.maxLines = 20,
        super.themeData})
      : super(key: key) {
    super.themeData ??= BrnFormItemConfig();
    super.themeData = BrnThemeConfigurator.instance
        .getConfig(configId: super.themeData!.configId)
        .formItemConfig
        .merge(super.themeData);
  }

  @override
  BrnTextBlockInputFormItemState createState() => _TextBlockInputFormItemState();
}

class _TextBlockInputFormItemState extends BrnTextBlockInputFormItemState {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
