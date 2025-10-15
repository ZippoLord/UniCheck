import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:prog24/login_or_register.dart';
import 'package:prog24/mainScreen.dart';
import 'package:prog24/methodChannel.dart';
import 'package:prog24/nfc.dart';
import 'package:prog24/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginOrRegister(),
    );
  }
}


