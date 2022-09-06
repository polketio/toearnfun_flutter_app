import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  MyBackButton({this.onBack, Key? key}) : super(key: key);

  final Function? onBack;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.of(context).pop();
          }
        },
        icon: Image.asset('assets/images/icon-L-Arrow.png'));
  }
}

class IconText extends StatelessWidget {
  IconText(this.icon, this.text, {TextStyle? this.style});

  String text;
  String icon;
  TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: null,
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        splashFactory: NoSplash.splashFactory,
        //disable click effect
        overlayColor: MaterialStateProperty.all(
            Colors.transparent), //disable click effect
      ),
      icon: Image.asset(icon),
      label: Text(text, style: style),
    );
  }
}
