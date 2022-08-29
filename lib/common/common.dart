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
