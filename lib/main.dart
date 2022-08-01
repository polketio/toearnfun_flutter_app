import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toearnfun_flutter_app/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(390, 844),
        builder: (_, __) => MaterialApp(
          title: 'Startup Name Generator',
          theme: new ThemeData(
            primaryColor: Colors.white,
          ),
          home: new RootView(),
        ),
    );
  }
}
