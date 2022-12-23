import 'package:flutter/material.dart';
import 'package:gps_tracking/ui/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomeScreen.routeName,
      routes: {HomeScreen.routeName: (c) => HomeScreen()},
      debugShowCheckedModeBanner: false,
    );
  }
}
