import 'package:flutter/material.dart';
import 'page/homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      home: MyPage(), // Set MyPage as the home widget
    );
  }
}
